# Bug Bash: standalone DF PowerShell SDK

## Background

Today, the DF PowerShell SDK is built-in to the PowerShell worker. This has some benefits, but it creates operational challenges:

- SDK release speed is bound to the worker release cadence
- SDK breaking changes are only possible when worker makes a breaking release

and others that are omitted for brevity.

In response, we've developed a new standalone DF PowerShell SDK that users will install as a separate package.
This package is mostly backwards compatible with the existing SDK. It also contains performance improvements
and supports SubOrchestrators.

## Pre-requisites

This assumes basic familiarity with Durable Functions. If you're stuck though, please ask for help!

You'll need core tools version v4.0.5095+. Please run `func --version` to ensure your core tools version is compatible.

## How to try it out

This repo already contains the basic project structure for a function-chaining Durable Functions PowerShell app.
You may use this as the starting point for your testing.

### 1. Install the SDK from the PowerShell Gallery

You'll notice an empty "Modules" directory. That's where the SDK needs
to be installed.

Run the following PowerShell command to install it.

```powershell
Save-Module -Name AzureFunctions.PowerShell.Durable.SDK -AllowPrerelease -Path ".\Modules"
```

### 2. Import the SDK in your `profile.ps1`.

This has been done for you in this repo's starter project.
Please verify that the `profile.ps1` file contains the following line:

```powershell
Import-Module AzureFunctions.PowerShell.Durable.SDK -ErrorAction Stop
```

### 3. Set the env variable `ExternalDurablePowerShellSDK` to `"true"`.

This has been done for you in this repo's starter project.
Please verify that this setting is set in your `local.settings.json`.

### 4. Run func extension install

Unfortunately, DF Extension 2.9.1 is not on bundles yet, so we cannot
test with bundles. We've created an `extensions.csproj` for you, please
use it to manage extensions.

Run `func extensions install` on your terminal to install the DF and AzStorage extensions.

### 5. Try it!

Run `func host start` and run the orchestrator with a GET request to `http://localhost:7071/api/orchestrators/DurableFunctionsOrchestrator`.

### 6. Confirm you're using the new SDK

Since the new SDK is backwards compatible with the old one, it's worth doing a sanity check that you are actually using the new experience.

To do this, run `func host start --verbose` and then CTRL+F for the following log: `Utilizing external Durable Functions SDK: 'True'`. If you can find it, you're using the new experience.

## Bug finding ideas

*Serialization bugs:*
Ensure different datatypes serialize correctly. This is a standard paint point in out of process SDKs.
Test this by providing different kinds of values as the inputs and outputs to DF APIs.

For example, return a deeply nested hashtable in an activity and ensure the table is fully reconstructed when received by the orchestrator.

*Test that exceptions are handled correctly:*
Ensure exception-throwing and exception-catching behavior works as expected in Activities, Sub-Orchestrators, and so on.

*Ensure all DF APIs work correctly:*
Test the different parameters to DF APIs and ensure that they all work as expected.

*Try different OS and platforms*
Does the SDK work on Linux? Does it work on an M1 Mac? Let's make sure the SDK actually works for all our customer dev environments.

## If you deploy to Azure

You will need to set the `ExternalDurablePowerShellSDK` application setting to `"true"`.