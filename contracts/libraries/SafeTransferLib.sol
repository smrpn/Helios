// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

/// @notice Safe ETH and ERC-20 transfer library that gracefully handles missing return values
/// @author Modified from Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// License-Identifier: AGPL-3.0-only
library SafeTransferLib {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error ETHtransferFailed();
    error TransferFailed();
    error TransferFromFailed();

    /// -----------------------------------------------------------------------
    /// ETH Logic
    /// -----------------------------------------------------------------------

    function _safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            // transfer the ETH and store if it succeeded or not
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        if (!success) revert ETHtransferFailed();
    }

    /// -----------------------------------------------------------------------
    /// ERC-20 Logic
    /// -----------------------------------------------------------------------

    function _safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // get a pointer to some free memory
            let freeMemoryPointer := mload(0x40)
            // write the abi-encoded calldata into memory, beginning with the function selector
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // append the 'to' argument
            mstore(add(freeMemoryPointer, 36), amount) // append the 'amount' argument

            success := and(
                // set success to whether the call reverted, if not we check it either
                // returned exactly 1 (not just any non-zero data), or had no return data
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // we use 68 because the length of our calldata totals up like so: 4 + 32 * 2
                // we use 0 and 32 to copy up to 32 bytes of return data into the scratch space
                // counterintuitively, this call must be positioned second to the addition in the
                // order of operations or else returndatasize() will be zero during the computation
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        if (!success) revert TransferFailed();
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // get a pointer to some free memory
            let freeMemoryPointer := mload(0x40)
            // write the abi-encoded calldata into memory, beginning with the function selector
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // append the 'from' argument
            mstore(add(freeMemoryPointer, 36), to) // append the 'to' argument
            mstore(add(freeMemoryPointer, 68), amount) // append the 'amount' argument

            success := and(
                // set success to whether the call reverted, if not we check it either
                // returned exactly 1 (not just any non-zero data), or had no return data
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // we use 100 because the length of our calldata totals up like so: 4 + 32 * 3
                // we use 0 and 32 to copy up to 32 bytes of return data into the scratch space
                // counterintuitively, this call must be positioned second to the addition in the
                // order of operations or else returndatasize() will be zero during the computation
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        if (!success) revert TransferFromFailed();
    }
}
