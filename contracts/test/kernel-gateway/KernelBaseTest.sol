pragma solidity >=0.5.0 <0.6.0;

import "../../kernel-gateway/KernelBase.sol";

contract KernelBaseTest is KernelBase {

    function setChainId(
        bytes20 _chainId
    )
        external
    {
        chainId = _chainId;
    }

    function setNonce(
        uint256 _nonce
    )
        external
    {
        nonce = _nonce;
    }

    function setLatestKernelHeight(
        uint256 _latestKernelHeight
    )
        external
    {
        latestKernelHeight = _latestKernelHeight;
    }

    function setLatestGasTarget(
        uint256 _latestGasTarget
    )
        external
    {
        latestGasTarget = _latestGasTarget;
    }

    function setKernelMessage(
        bytes32 _key,
        bytes32 _value
    )
        external
    {
        kernelMessages[_key] = _value;
    }

    function callKernelTypeHash(
        uint256 _height,
        bytes32 _parent,
        address[] calldata _updatedValidators,
        uint256[] calldata _updatedReputation,
        uint256 _gasTarget

    )
        external
        pure
        returns (bytes32 kernelTypeHash_)
    {
        kernelTypeHash_ = kernelTypeHash(
            _height,
            _parent,
            _updatedValidators,
            _updatedReputation,
            _gasTarget
        );
    }
}
