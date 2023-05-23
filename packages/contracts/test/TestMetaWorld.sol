pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../src/MetaWorld.sol";
import { console } from "forge-std/console.sol";

contract TestMetaWorld is Test {
    MetaWorld metaWorld;

    function setUp() public {
        metaWorld = new MetaWorld();
    }

    function test_fullcall() public {
        console.log("gogogo");
        metaWorld.f3Spawn();
    }
}
