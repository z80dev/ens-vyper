// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { ENSRegistry } from "ens-contracts/registry/ENSRegistry.sol";
import { ENS } from "ens-contracts/registry/ENS.sol";
import { FIFSRegistrar } from "ens-contracts/registry/FIFSRegistrar.sol";
import { VyperDeployer } from "utils/VyperDeployer.sol";

contract FIFSRegistrarTest is Test {

    ENSRegistry public solRegistry;
    ENSRegistry public vyRegistry;
    FIFSRegistrar public solRegistrar;
    FIFSRegistrar public vyRegistrar;
    VyperDeployer vyperDeployer = new VyperDeployer();
    bytes32 rootNode = bytes32(0x0);

    function setUp() public {
        // deploy registries
        solRegistry = new ENSRegistry();
        vyRegistry = ENSRegistry(vyperDeployer.deployContract("registry/ENSRegistry"));

        // take ownership of vyper registry from deployer
        vm.prank(address(vyperDeployer));
        vyRegistry.setOwner(bytes32(0x0), address(this));

        solRegistrar = new FIFSRegistrar(ENS(solRegistry), rootNode);
        vyRegistrar = FIFSRegistrar(vyperDeployer.deployContract("registry/FIFSRegistrar", abi.encode(address(vyRegistry), rootNode)));

        solRegistry.setOwner(bytes32(0x0), address(solRegistrar));
        vyRegistry.setOwner(bytes32(0x0), address(vyRegistrar));

        // take ownership of .eth
        solRegistrar.register(keccak256("eth"), address(this));
        vyRegistrar.register(keccak256("eth"), address(this));
    }

    function testGasNameRegistration() public {
        solRegistrar.register(keccak256("gas"), address(this));
        vyRegistrar.register(keccak256("gas"), address(this));
    }

    function testNameRegistration() public {
        solRegistrar.register(keccak256("test"), address(this));
        assertEq(solRegistry.owner(keccak256(abi.encodePacked(rootNode, keccak256("test")))), address(this));
        vyRegistrar.register(keccak256("test"), address(this));
        assertEq(vyRegistry.owner(keccak256(abi.encodePacked(rootNode, keccak256("test")))), address(this));
    }

    function testGasNameTransfer() public {
        solRegistrar.register(keccak256("eth"), address(1234));
        vyRegistrar.register(keccak256("eth"), address(1234));
    }

    function testNameTransfer() public {
        solRegistrar.register(keccak256("eth"), address(1234));
        vyRegistrar.register(keccak256("eth"), address(1234));

        assertEq(solRegistry.owner(keccak256(abi.encodePacked(rootNode, keccak256("eth")))), address(1234));
        assertEq(vyRegistry.owner(keccak256(abi.encodePacked(rootNode, keccak256("eth")))), address(1234));
    }

    function testOwnershipEnforced() public {
        vm.startPrank(address(1234));
        vm.expectRevert();
        solRegistrar.register(keccak256("eth"), address(1234));
        vm.expectRevert();
        vyRegistrar.register(keccak256("eth"), address(1234));

    }

}
