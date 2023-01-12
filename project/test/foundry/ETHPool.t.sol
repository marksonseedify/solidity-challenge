// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ETHPool} from "../../src/ETHPool.sol";

contract ETHPoolTest is Test {
    address public constant FORGE = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;

    ETHPool public pool;

    function setUp() public {
        pool = new ETHPool();
    }

    /*//////////////////////////////////////////////////////////////
                                 BASIC ATTRIBUTES
    //////////////////////////////////////////////////////////////*/
    function test_owner_isForgeDeployer() public {
        assertTrue(pool.owner() == FORGE);
    }
}
