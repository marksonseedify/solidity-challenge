// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ETHPool} from "../../src/ETHPool.sol";

contract ETHPoolTest is Test {
    ETHPool public pool;

    function setUp() public {
        pool = new ETHPool();
    }

    /*//////////////////////////////////////////////////////////////
                                 BASIC ATTRIBUTES
    //////////////////////////////////////////////////////////////*/
    function test_() public {
        assertTrue(true);
    }
}
