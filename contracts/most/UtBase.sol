pragma solidity >=0.5.0 <0.6.0;

// Copyright 2020 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import "./GenesisUtBase.sol";
import "../consensus/CoconsensusModule.sol";
import "../proxies/MasterCopyNonUpgradable.sol";
import "../utility-token/ERC20Token.sol";

/**
 * @title UtBase is an ERC20 token wrapper for the base coin that is used to
 *        pay for gas consumption on the auxiliary chain.
 */
contract UtBase is MasterCopyNonUpgradable, GenesisUtBase, ERC20Token, CoconsensusModule {

    /* Constants */

    /** Token Symbol */
    string public constant TOKEN_SYMBOL = "UB";

    /** Token Name */
    string public constant TOKEN_NAME = "UtBase";

    /** Token Decimal */
    uint8 public constant TOKEN_DECIMALS = 18;


    /* Storage */

    /** Consensus cogateway address defined in genesis. */
    address private consensusCogateway = address(0x0000000000000000000000000000000000004d02);


    /* Modifiers */

    modifier onlyConsensusCogateway()
    {
        require(
            msg.sender == getConsensusCogateway(),
            "Only the consensus cogateway contract can call this function."
        );
        _;
    }


    /* External Functions */

    /**
     * @notice Initializes the UtBase contract.
     *
     * \pre Can be called only once by consensus cogateway contract
     *
     * \post Sets the `tokenSymbol` storage variable with `TOKEN_SYMBOL`
     *       constant value.
     * \post Sets the `tokenName` storage variable with `TOKEN_NAME`
     *       constant value.
     * \post Sets the `tokenDecimals` storage variable with `TOKEN_DECIMALS`
     *       constant value.
     * \post Sets the `totalTokenSupply` storage variable to genesis total
     *       supply value.
     * \post Adds the balance for the (self) contract address with genesis
     *       total supply value.     */
    function setup()
        external
        onlyCoconsensus
    {
        require(
            totalTokenSupply == uint256(0),
            "Utbase contract is already initialized."
        );

        tokenSymbol = TOKEN_SYMBOL;
        tokenName = TOKEN_NAME;
        tokenDecimals = TOKEN_DECIMALS;
        totalTokenSupply = genesisTotalSupply;

        /*
         * In the genesis block, validators gets base token equivalent to the
         * amount they deposited before joining the core. Equivalent
         * amount of ERC20 token should be minted and UtBase contract should
         * hold that balance. Similar flow will happen in normal mint process
         * where UtBase contract ERC20 balance will be incremented. So in the
         * setup, UtBase contract holds the ERC20 token balance equal to the
         * genesisTotalSupply.
         */
        balances[address(this)] = genesisTotalSupply;
    }

    /**
     * @notice Mints the ERC20 token for the beneficiary address and
     *         unwraps its to base coin.
     *
     * @param _beneficiary Beneficairy address which will receive base coin.
     * @param _amount Amount of UtBase tokens to be minted.
     *
     * \pre Caller must be Consensus cogateway contract.
     *
     * \post Increases total token supply by `_amount `.
     * \post Increase ERC20 UtBase token balance of the beneficiary
     *       by `_amount`.
     * \post It satisfies all post conditions of UtBase::unwrapInternal().
     *
     *
     */
    function mint(
        address payable _beneficiary,
        uint256 _amount
    )
        external
        onlyConsensusCogateway
    {
        _mint(_beneficiary, _amount);
        unwrapInternal(_beneficiary, _amount);
    }

    /**
     * @notice Unwrap converts ERC20 UtBase to base coin.
     *
     * @dev This contract's base coin balance must always be greater than
     *       amount.
     *
     * @param _amount Amount of ERC20 UtBase token to convert to base coin.
     *
     * \pre Satisfies all conditions of UtBase::unwrapInternal.
     *
     * \post Satisfies all conditions of UtBase::unwrapInternal.
     *
     */
    function unwrap(
        uint256 _amount
    )
        external
    {
        unwrapInternal(msg.sender, _amount);
    }

    /**
     * @notice Wrap converts base coin to ERC20 UtBase.
     *
     * @dev The ERC20 OST balance of contract should always be greater than the
     *      received payable amount.
     *
     * \pre msg.value should be non-zero.
     * \pre UtBase ERC20 token balance must be greater than
     *      amount to be wrapped.
     *
     * \post Increases ERC20 UtBase token balance of the caller by `msg.value`
     *        amount.
     * \post Decreases ERC20 UtBase token balance of the UtBase contract by
     *       `msg.value` amount.
     */
    function wrap()
        external
        payable
    {
        uint256 amount = msg.value;
        address account = msg.sender;

        require(
            amount > 0,
            "Payable amount should not be zero."
        );

        assert(balances[address(this)] >= amount);

        transferBalance(address(this), account, amount);
    }

    /**
     * @notice It allows to burn UtBase tokens for an account.
     *
     * @param _value The amount that will be burnt.
     *
     * \pre msg.value should be non-zero.
     * \pre Caller must have atleast `_value` amount of ERC20 UtBase tokens.
     *
     * \post Decreases total token supply of the token by `_value` amount.
     * \post Decreases caller's ERC20 UtBase token balance by `_value` amount.
     *
     */
    function burn(uint256 _value)
        external
    {
        _burn(msg.sender, _value);
    }

    /**
     * @notice It allows to burn tokens of the spender.
     *
     * @param _account The account whose tokens will be burnt.
     * @param _value The amount that will be burnt.
     *
     * \pre `_account` must approve `_value` amount to the caller
     *
     * \post Decreases total token supply of the token by `_value` amount.
     * \post Decreases `_account` ERC20 UtBase token balance by
     *       `_value` amount.
     */
    function burnFrom(address _account, uint256 _value)
        external
    {
        _burnFrom(_account, _value);
    }


    /* Public Functions */

    /**
     * @notice Gets the consensus cogateway contract address.
     *
     * @return Consensus cogateway contract address.
     */
    function getConsensusCogateway() public view returns(address) {
        return consensusCogateway;
    }

    /**
     * @notice Gets total token supply.
     *
     * @return Token token supply.
     */
    function getTotalTokenSupply() public view returns(uint256) {
        return totalTokenSupply;
    }


    /* Internal Functions */

    /**
     * @notice Internal method to transfer the base coin equivalent amount to
     *         beneficiary address.
     *
     * @param _beneficiary Beneficairy address which will receive base coin.
     * @param _amount Amount of ERC20 UtBase tokens to be unwrapped.
     *
     * \pre `amount` must be less than or equal to beneficiary token balance.
     * \pre UtBase contract base token balance must be greater than or
     *      equal to `amount`.
     *
     * \post UtBase contract receives `_amount` number of ERC20 UtBase tokens.
     * \post `_beneficiary` address receives `_amount` number of base coins.
     *
     */
    function unwrapInternal(
        address payable _beneficiary,
        uint256 _amount
    )
        internal
    {
        require(
            _amount <= balances[_beneficiary],
            "Insufficient balance."
        );

        assert(address(this).balance >= _amount);

        transferBalance(_beneficiary, address(this), _amount);

        _beneficiary.transfer(_amount);
    }
}
