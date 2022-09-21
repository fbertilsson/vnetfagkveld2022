# VNet Fagkveld 2022

## Overview

This demos two aspects of Azure VNet networking which you can use to secure apps if you must:

* Private Endpoint
* VNet Integration

There are several security concerns you should address before deciding to also implement these.

## Scenario

You have a solar calculation component `solarcalc` with an HTTP interface which is valuable, unmodifiable and whose interface should be protected by more than authentication/authorization - it should not be accessible on the network level at all. Maybe you have a policy to comply with or you just need that extra layer of security.

You create a function app `greenapi` to sit in front of the `solarcalc` component.

To protect `solarcalc`, you create a virtual network and an Azure Private Endpoint for `solarcalc`, shielding it from any outside network traffic. That also makes it inaccessible to the `greenapi`.

To make it accessible to `greenapi` you enable `VNet Integration` on `greenapi` so that it can send IP traffic into the VNet.

## Branches

There will be several branches in the repo:

| Branch | Description |
|--------|-------------|
| start  | There is a VNet, but no app is associated. Start here. |
| private-endpoint | `Solarcalc` has a private endpoint and is therefore inaccessible outside of the VNet. |
| main   | `Greenapi` has VNet integration enabled and can access `solarcalc` even though it has a private endpoint.
