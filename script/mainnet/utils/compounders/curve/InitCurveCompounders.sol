// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "script/mainnet/utils/compounders/curve/InitPETH.sol";
import "script/mainnet/utils/compounders/curve/InitFXScvxFXS.sol";
import "script/mainnet/utils/compounders/curve/InitETHfrxETH.sol";

contract InitCurveCompounders is InitPETH, InitFXScvxFXS, InitETHfrxETH {

    function _initializeCurveCompounders(address _owner, address _fortressRegistry, address _fortressSwap, address _platform) internal returns (address frxEthCompounder) {
        
        // ------------------------- pETH/ETH -------------------------
        _initializePETH(_owner, _fortressRegistry, _fortressSwap, _platform);

        // ------------------------- cvxFXS/FXS -------------------------
        _initializeFXScvxFXS(_owner, _fortressRegistry, _fortressSwap, _platform);

        // ------------------------- ETH/frxETH -------------------------
        frxEthCompounder = _initializeETHfrxETH(_owner, _fortressRegistry, _fortressSwap, _platform);
    }
}
