// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";

import { Systems } from "@latticexyz/world/src/modules/core/tables/Systems.sol";
import { SystemHooks } from "@latticexyz/world/src/modules/core/tables/SystemHooks.sol";
import { FunctionSelectors } from "@latticexyz/world/src/modules/core/tables/FunctionSelectors.sol";
import { AccessControl } from "@latticexyz/world/src/AccessControl.sol";
import { ISystemHook } from "@latticexyz/world/src/interfaces/ISystemHook.sol";
import { Call } from "@latticexyz/world/src/Call.sol";
import { console } from "forge-std/console.sol";

bytes16 constant ROOT_NAMESPACE = 0;

contract SpooferSystem is System {

  using ResourceSelector for bytes32;

  error SpoofedFunctionSelectorNotFound(bytes4 functionSelector);
  error SpooferResourceNotFound(string resource);

  /**
   * Call the system at the given namespace and name.
   * If the system is not public, the caller must have access to the namespace or name.
   */
  function spoofCall(
    bytes memory callBytes,
    address spoofedSender
  ) external payable virtual returns (bytes memory) {
    console.log("spoofCall");
    bytes4 callSignature = bytes4(callBytes[0]) | bytes4(callBytes[1]) >> 8 | bytes4(callBytes[2]) >> 16 | bytes4(callBytes[3]) >> 24;

    (bytes16 namespace, bytes16 name, bytes4 systemFunctionSelector) = FunctionSelectors.get(callSignature);
    console.log("namespace: ");
    console.logBytes16(namespace);
    console.log("name: ");
    console.logBytes16(name);
    console.log("callSignature: ");
    console.logBytes4(callSignature);
    console.log(address(this));
    console.log(address(this));
    (string memory strt, string[] memory strarr) = FunctionSelectors.getMetadata();
    console.log("strt ");
    console.log(strt);
    console.log(strarr[0]);
    console.log(strarr[1]);
    console.log(strarr[2]);
    console.log(strarr[3]);
    console.log(strarr[4]);
    console.log(strarr[5]);
    console.log(strarr[6]);
    console.log(strarr[7]);
    console.log("strt_done");

    if (namespace == 0 && name == 0) revert SpoofedFunctionSelectorNotFound(msg.sig);

    // Replace function selector in the calldata with the system function selector
    bytes memory callData = Bytes.setBytes4(msg.data, 0, systemFunctionSelector);

    console.log("_call() with: ");
    console.log("namespace: ");
    console.logBytes16(namespace);

    // Call the function and forward the call value
    bytes memory returnData = _call(namespace, name, callData, msg.value, spoofedSender);
    assembly {
      return(add(returnData, 0x20), mload(returnData))
    }
  }

  /**
   * Call the system at the given namespace and name and pass the given value.
   * If the system is not public, the caller must have access to the namespace or name.
   */
  function _call(
    bytes16 namespace,
    bytes16 name,
    bytes memory funcSelectorAndArgs,
    uint256 value,
    address spoofedSender
  ) internal virtual returns (bytes memory data) {
    // Load the system data
    bytes32 resourceSelector = ResourceSelector.from(namespace, name);
    (address systemAddress, bool publicAccess) = Systems.get(resourceSelector);

    // Check if the system exists
    if (systemAddress == address(0)) revert SpooferResourceNotFound(resourceSelector.toString());

    // Allow access if the system is public or the caller has access to the namespace or name
    if (!publicAccess) AccessControl.requireAccess(namespace, name, spoofedSender);

    // Get system hooks
    address[] memory hooks = SystemHooks.get(resourceSelector);

    // Call onBeforeCallSystem hooks (before calling the system)
    for (uint256 i; i < hooks.length; i++) {
      ISystemHook hook = ISystemHook(hooks[i]);
      hook.onBeforeCallSystem(spoofedSender, systemAddress, funcSelectorAndArgs);
    }

    // Call the system and forward any return data
    data = Call.withSender({
      msgSender: spoofedSender,
      target: systemAddress,
      funcSelectorAndArgs: funcSelectorAndArgs,
      delegate: namespace == ROOT_NAMESPACE, // Use delegatecall for root systems (= registered in the root namespace)
      value: value
    });

    // Call onAfterCallSystem hooks (after calling the system)
    for (uint256 i; i < hooks.length; i++) {
      ISystemHook hook = ISystemHook(hooks[i]);
      hook.onAfterCallSystem(spoofedSender, systemAddress, funcSelectorAndArgs);
    }
  }

}
