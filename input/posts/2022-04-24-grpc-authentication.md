---
layout: post.liquid
title: Using Service Identity in Google Cloud Run to authenticate gRPC requests
published_date: 2022-04-24 15:23:00 -07:00
permalink: /{{year}}/{{month}}/{{day}}/{{slug}}{{ext}}
---

When writing a backend microservice, it is good idea to limit who can access the
service. If you are running your service on
[Google Cloud Run](https://cloud.google.com/run),
one tool you can use to control access to your service is
[service-to-service authentication with service identities](https://cloud.google.com/run/docs/authenticating/service-to-service).
See the linked article for me details, but the basic idea is:

1. Configure every service to use a unique [service identity](https://cloud.google.com/run/docs/securing/service-identity#per-service-identity).
2. On each service, for each service identity that needs access to the service,
   assign the corresponding service identity the `roles/run.invoker` role.
3. When invoking the service, include an identity token to authenticate the
   request.

This post will cover the third step when using gRPC and ASP.NET. For steps one
and two I used
[Pulumi](https://www.pulumi.com/)
to
[setup the services and accounts](https://github.com/AustinWise/GrpcMicroservicesOnGoogleCloudRun/blob/4484c53456b252b90187d67cc349f2782a18f0d6/Infra/PulumiInfra/MyStack.cs),
but that is the subject of a future blog post.

## Prerequisites

We will need a few Nuget packages:

* [Google.Apis.Auth](https://www.nuget.org/packages/Google.Apis.Auth/)
* [Grpc.AspNetCore](https://www.nuget.org/packages/Grpc.AspNetCore/)

In your `.csproj` file, reference the `.proto` file for the service you will be
calling. Here is my complete file:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

	<PropertyGroup>
		<TargetFramework>net6.0</TargetFramework>
		<ImplicitUsings>enable</ImplicitUsings>
		<Nullable>enable</Nullable>
	</PropertyGroup>

	<ItemGroup>
		<Protobuf Include="greet.proto" GrpcServices="Both" />
	</ItemGroup>

	<ItemGroup>
		<PackageReference Include="Google.Apis.Auth" Version="1.56.0" />
		<PackageReference Include="Grpc.AspNetCore" Version="2.43.0" />
	</ItemGroup>
</Project>
```

My `greet.proto` file contains the following:

```proto
syntax = "proto3";

option csharp_namespace = "GrpcContracts.Greeters";

package greet;

// The greeting service definition.
service Greeter {
  // Sends a greeting
  rpc SayHello (HelloRequest) returns (HelloReply);
}

// The request message containing the user's name.
message HelloRequest {
  string name = 1;
}

// The response message containing the greetings.
message HelloReply {
  string message = 1;
}
```

## Registering the gRPC

Let's first register our greater service with ASP.NET Core's dependency injection
system. This uses the
[gRPC client factory integration](https://docs.microsoft.com/aspnet/core/grpc/clientfactory)
in ASP.NET Core. In our `Program.cs` file we write:

```c#
using Google.Apis.Auth.OAuth2;
using Grpc.Core;
using GrpcContracts.Greeters;

string serviceUrl = "https://backend-service.run.app";
Uri serviceUri = new Uri(serviceUrl);
builder.Services.AddGrpcClient<Greeter.GreeterClient>(o =>
{
    o.Address = serviceUri;
});
```

Where `https://backend-service.run.app` is the address of the Google Cloud Run
hosted service we wish to connect to. This allows use to use the server via
dependency injection in our controllers:

```c#
public class HomeController : Controller
{
    private readonly Greeter.GreeterClient _greeter;

    public HomeController(Greeter.GreeterClient greeter)
    {
        _greeter = greeter;
    }
    
    public async Task<IActionResult> Index()
    {
        var res = await _greeter.SayHelloAsync(new HelloRequest()
        {
            Name = "frontend"
        });

        // Cast to object so that it is used as the Model, not a view name.
        return View((object)res.Message);
    }
```

## Add authentication using service identity

Let's use add some authentication using the default service identity for the
Google Cloud Run service we are running in:

```c#
string serviceUrl = "https://backend-service.run.app";
Uri serviceUri = new Uri(serviceUrl);
var cred = new ComputeCredential();
var token = await cred.GetOidcTokenAsync(OidcTokenOptions.FromTargetAudience(serviceUrl));
var grpc = builder.Services.AddGrpcClient<Greeter.GreeterClient>(o =>
{
    o.Address = serviceUri;
});
grpc.ConfigureChannel(o => {
    var credentials = CallCredentials.FromInterceptor(async (context, metadata) =>
    {
        string tokenValue = await token.GetAccessTokenAsync();
        metadata.Add("Authorization", $"bearer {tokenValue}");
    });

    o.Credentials = ChannelCredentials.Create(new SslCredentials(), credentials);
});
```

The call to `token.GetAccessTokenAsync()` basically returns the body returned by
`http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity`,
passing the service URL as the `audience` query string parameter. It will also
handle caching the token so we don't have to constantly get a new token.

We could use `ComputeCredential.IsRunningOnComputeEngine()` to determine if our
application is run in Google Cloud Run. We could then only add the token in that
case. But instead in the next section we will make it possible to call our
service from outside Google Cloud Run.

## Impersonating our service account on our local computer for testing

For testing purposes it can be helpful to call your service running in Google
Cloud Run from your local computer. In this case you can impersonate the service
account locally. You will need to logged into the Google Cloud CLI locally and
have the
[appropriate roles assigned to your account](https://cloud.google.com/iam/docs/impersonating-service-accounts).

You can then change the way you get the token to support service account
impersonation:

```c#
string serviceIdentity = "frontend-service@my-project.iam.gserviceaccount.com";
var cred = await GoogleCredential.GetApplicationDefaultAsync();
if (cred.UnderlyingCredential is not IOidcTokenProvider)
{
    cred = cred.Impersonate(new ImpersonatedCredential.Initializer(serviceIdentity));
}
var token = await cred.GetOidcTokenAsync(OidcTokenOptions.FromTargetAudience(serviceUrl));
```

`frontend-service@my-project.iam.gserviceaccount.com` is the email address of
the service identity.

The call to `GoogleCredential.GetApplicationDefaultAsync()` will return a
`ComputeCredential` like before if we are running in Google Cloud Run. If you
are running locally it will return your personal credential. This credential
can be used to impersonate the service account and call our backend service.

## Support for running all services locally

One assumption the previous code examples made was you always would have a
credential to attach to a request. If you are running both your frontend and
backend on your local computer for testing, no credential should be required.

To support this use case, I skip looking up a credential if the service address
is something like `localhost` or `127.0.0.1`. See
[this helper function](https://github.com/AustinWise/GrpcMicroservicesOnGoogleCloudRun/blob/27f817c5dde8d505fb8050da3b228ffb0fc9fe9c/GrpcContracts/GoogleAuthConfigurationExtensions.cs)
that factors all the logic for connecting to a service and using a Google Cloud
Run service identity token if available. It can be used like this:

```c#
await builder.Services.AddGrpcClientWithGcpServiceIdentityAsync<Greeter.GreeterClient>(
    "https://backend-service.run.app",
    "frontend-service@my-project.iam.gserviceaccount.com"
);
```

## Conclusion

We saw how to support authenticating requests to gRPC services running on Google
Cloud Run. To see the complete code behind this post, check out
[this GitHub project](https://github.com/AustinWise/GrpcMicroservicesOnGoogleCloudRun).
It has the source code for the a front end web service connecting to a backend
gRPC service. It is deployed using the Pulumi CLI.
