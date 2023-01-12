// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ETHPoolTestSetUp} from "./setUp/ETHPoolTestSetUp.t.sol";

contract ETHPoolTest_Owner is ETHPoolTestSetUp {
    function setUp() public override {
        super.setUp();
    }

    /*//////////////////////////////////////////////////////////////
                                 BASIC ATTRIBUTES
    //////////////////////////////////////////////////////////////*/
    function test_owner_isForgeDeployer() public {
        assertTrue(pool.owner() == users.FORGE());
    }
}
