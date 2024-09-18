// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import {console2} from "forge-std/Script.sol";
import {DeployCoreLocal} from "./DeployCoreLocal.sol";
import {Core} from "../../src/Core.sol";
import {VaultLib} from "../../src/entities/VaultLib.sol";
import {RestakingRegistry} from "../../src/registry/RestakingRegistry.sol";
import {Constants} from "../../src/interfaces/Constants.sol";
import {IKarakBaseVault} from "../../src/interfaces/IKarakBaseVault.sol";

contract SetupCoreLocal {
    address operator = address(this);

    function run() public {
        DeployCoreLocal dcl = new DeployCoreLocal();
        (
            address coreImpl,
            address vaultImpl,
            address slashingHandlerImpl,
            address registryImpl,
            address nativeVaultImpl,
            address nativeNodeImpl,
            address testERC20Addr,
            Core coreProxy,
            RestakingRegistry registryProxy
        ) = dcl.run();

        VaultLib.Config[] memory vaultConfigs = new VaultLib.Config[](1);

        // Add native asset
        vaultConfigs[0] = VaultLib.Config({
            asset: Constants.NATIVE_ASSET_ADDR,
            decimals: 18,
            operator: operator,
            name: "NativeTestVault",
            symbol: "NTV",
            extraData: abi.encode(operator, nativeNodeImpl)
        });

        IKarakBaseVault[] memory vaults = coreProxy.deployVaults(vaultConfigs, nativeVaultImpl);
        IKarakBaseVault nativeVault = vaults[0];
        console2.log("Native Vault (proxy):", address(nativeVault));

        vaultConfigs[0] = VaultLib.Config({
            asset: testERC20Addr,
            decimals: 6,
            operator: operator,
            name: "TestVault",
            symbol: "TV",
            extraData: "0x"
        });

        vaults = coreProxy.deployVaults(vaultConfigs, address(0));
        console2.log("ERC20 Vault (proxy):", address(vaults[0]));
    }
}
