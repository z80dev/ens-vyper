// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { ENSRegistry } from "ens-contracts/registry/ENSRegistry.sol";
import { VyperDeployer } from "utils/VyperDeployer.sol";

contract ENSRegistryTest is Test {

    ENSRegistry public solRegistry;
    ENSRegistry public vyRegistry;
    VyperDeployer vyperDeployer = new VyperDeployer();

    function setUp() public {
        solRegistry = new ENSRegistry();
        vyRegistry = ENSRegistry(vyperDeployer.deployContract("registry/ENSRegistry"));
        vm.prank(address(vyperDeployer));
        vyRegistry.setOwner(bytes32(0x0), address(this));
    }

    function testAllowOwnershipTransfers() public {
        solRegistry.setOwner(bytes32(0x0), address(1234));
        vyRegistry.owner(bytes32(0x0));
        vyRegistry.setOwner(bytes32(0x0), address(1234));
        assertEq(solRegistry.owner(bytes32(0x0)), address(1234));
        assertEq(vyRegistry.owner(bytes32(0x0)), address(1234));
        assertEq(solRegistry.owner(bytes32(0x0)), vyRegistry.owner(bytes32(0x0)));
    }

    function testSubnode() public {
        bytes32 subnode = keccak256(abi.encodePacked(bytes32(0x0), keccak256('eth')));
        solRegistry.setSubnodeOwner(bytes32(0x0), keccak256('eth'), address(1234));
        vyRegistry.setSubnodeOwner(bytes32(0x0), keccak256('eth'), address(1234));
        assertEq(solRegistry.owner(subnode), vyRegistry.owner(subnode));
    }

    function testEnforcesOwnership() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        solRegistry.setOwner(bytes32(0x0), address(1234));
        vm.expectRevert("!auth");
        vyRegistry.setOwner(bytes32(0x0), address(1234));
    }

}
