// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address payable constant WORLD_1_ADDRESS = payable(0x5FbDB2315678afecb367f032d93F642f64180aa3);
import { console } from "forge-std/console.sol";

contract MetaWorld  {

  function f3Spawn() external payable returns (bytes memory) {
    console.log("Inside 1111");

    bytes memory moveCall = abi.encodeWithSelector(
      bytes4(keccak256("spawn(uint256,uint256)")),
      10,
      10
    );
    console.log("Inside 2222");

    (bool success, bytes memory data) = WORLD_1_ADDRESS.call{ value: msg.value }(
      abi.encodeWithSignature("spoofCall(bytes,address)",
      moveCall,
      msg.sender
    ));
    console.log("Inside 3333");

    require(success, "Spoofed call failed");

    return "success";
  }

}
