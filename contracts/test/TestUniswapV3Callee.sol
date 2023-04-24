// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '@pollum-io/v2-core/contracts/interfaces/callback/IPegasysV2SwapCallback.sol';
import '@pollum-io/v2-core/contracts/libraries/SafeCast.sol';
import '@pollum-io/v2-core/contracts/interfaces/IPegasysV2Pool.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract TestPegasysV2Callee is IPegasysV2SwapCallback {
    using SafeCast for uint256;

    function swapExact0For1(address pool, uint256 amount0In, address recipient, uint160 sqrtPriceLimitX96) external {
        IPegasysV2Pool(pool).swap(recipient, true, amount0In.toInt256(), sqrtPriceLimitX96, abi.encode(msg.sender));
    }

    function swap0ForExact1(address pool, uint256 amount1Out, address recipient, uint160 sqrtPriceLimitX96) external {
        IPegasysV2Pool(pool).swap(recipient, true, -amount1Out.toInt256(), sqrtPriceLimitX96, abi.encode(msg.sender));
    }

    function swapExact1For0(address pool, uint256 amount1In, address recipient, uint160 sqrtPriceLimitX96) external {
        IPegasysV2Pool(pool).swap(recipient, false, amount1In.toInt256(), sqrtPriceLimitX96, abi.encode(msg.sender));
    }

    function swap1ForExact0(address pool, uint256 amount0Out, address recipient, uint160 sqrtPriceLimitX96) external {
        IPegasysV2Pool(pool).swap(recipient, false, -amount0Out.toInt256(), sqrtPriceLimitX96, abi.encode(msg.sender));
    }

    function pegasysV2SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external override {
        address sender = abi.decode(data, (address));

        if (amount0Delta > 0) {
            IERC20(IPegasysV2Pool(msg.sender).token0()).transferFrom(sender, msg.sender, uint256(amount0Delta));
        } else {
            assert(amount1Delta > 0);
            IERC20(IPegasysV2Pool(msg.sender).token1()).transferFrom(sender, msg.sender, uint256(amount1Delta));
        }
    }
}
