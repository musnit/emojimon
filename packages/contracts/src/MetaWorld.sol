// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address payable constant WORLD_1_ADDRESS = payable(0x5FbDB2315678afecb367f032d93F642f64180aa3);

contract MetaWorld  {

  function f3Spawn() external payable returns (bytes memory) {
    bytes memory spawnCall = abi.encodeWithSelector(
      bytes4(keccak256("spawn(uint32,uint32)")),
      1,
      1
    );

    (bool success, bytes memory data) = WORLD_1_ADDRESS.call{ value: msg.value }(
      abi.encodeWithSignature("spoofCall(bytes,address)",
      spawnCall,
      msg.sender
    ));

    require(success, "failed");

    return "success";
  }

}
