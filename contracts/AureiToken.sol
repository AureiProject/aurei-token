pragma solidity ^0.5.11;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract AureiToken is ERC20Burnable, ERC20Detailed, ERC20Mintable {
  using SafeMath for uint;

  uint public currentValue;
  uint public declaredValue;
  uint public validatedValue;

  address public valueDeclarator;
  address public valueDeclaratorUpdater;
  address public valueValidator;
  address public recipient0;
  address public recipient1;

  event DeclaredValue(uint _value);
  event ValidatedValue(uint _value);

  uint public constant VALUE_THRESHOLD = 8000;
  uint public constant TOKENS_MINTED_PER_THRESHOLD = 50000000000;

  /**
  * @dev The constructor mints all initial tokens and sends them to an address
  * @param _initialRecipient the account that will get all tokens
  * @param _initialSupply the initial number of tokens to be minted
  * @param _initialValue the initial value
  * @param _valueDeclarator the value declarator
  * @param _valueDeclaratorUpdater the address allowed to update the value declarator
  * @param _valueValidator the value validator
  * @param _recipient0 the first recipient address
  * @param _recipient1 the second recipient address
  **/
  constructor(
    address _initialRecipient,
    uint _initialSupply,
    uint _initialValue,
    address _valueDeclarator,
    address _valueDeclaratorUpdater,
    address _valueValidator,
    address _recipient0,
    address _recipient1
    )
    public
    ERC20Detailed("Aurei", "ARE", 8)
  {
    // set contract variables
    currentValue = _initialValue;
    valueDeclarator = _valueDeclarator;
    valueDeclaratorUpdater = _valueDeclaratorUpdater;
    valueValidator = _valueValidator;
    validatedValue = _initialValue;
    declaredValue = _initialValue;
    recipient0 = _recipient0;
    recipient1 = _recipient1;
    // mint initial supply
    mint(_initialRecipient, _initialSupply);
    // renounce to Minter role and give it to present contract
    addMinter(address(this));
    renounceMinter();
  }

  /**
  * @dev The declareValue function lets the valueDeclarator declare a new value when it is reached to
  * allow the valueValidator to mint new tokens accordingly.
  * @param _value the new validated value
  * @notice This function can only be called by the valueDeclarator.
  **/
  function declareValue(uint _value) external {
    require(msg.sender == valueDeclarator, "validation can only be called by designated valueDeclarator");
    require(_value > currentValue, "new declared value should be higher than current value");
    require(_value > declaredValue, "new declared value should be higher than the last one");
    declaredValue = _value;
    // emit an event
    emit DeclaredValue(_value);
    // update current value and mint new tokens if possible
    updateCurrentValue();
  }

  /**
  * @dev The validateValue function lets the valueValidator accept to mint tokens when values are reached.
  * @param _value a new value to declare
  * @notice This function can only be called by the valueValidator
  **/
  function validateValue(uint _value) external {
    require(msg.sender == valueValidator, "validation can only be called by designated valueValidator");
    require(_value > currentValue, "new validated value should be higher than current value");
    require(_value > validatedValue, "new validated value should be higher than the last one");
    validatedValue = _value;
    // emit an event
    emit ValidatedValue(_value);
    // update current value and mint new tokens if possible
    updateCurrentValue();
  }

  /**
  * @dev The updateCurrentValue function updates currentValue and mints new tokens accordingly.
  **/
  function updateCurrentValue() private {
    uint newValue = (validatedValue < declaredValue) ? validatedValue : declaredValue;
    uint lastNbThresholds = currentValue.div(VALUE_THRESHOLD);
    uint newNbThresholds = newValue.div(VALUE_THRESHOLD);
    currentValue = newValue;
    if (lastNbThresholds < newNbThresholds) {
      uint newTokensPerRecipient = newNbThresholds.sub(lastNbThresholds).mul(TOKENS_MINTED_PER_THRESHOLD).div(2);
      _mint(recipient0, newTokensPerRecipient);
      _mint(recipient1, newTokensPerRecipient);
    }
  }

  /**
  * @dev The changeValueDeclarator function lets the valueDeclaratorUpdater change valueDeclarator's address.
  * @param _newAddress the new valueDeclarator address
  * @notice This function can only be called by the current valueDeclaratorUpdater address.
  **/
  function changeValueDeclarator(address _newAddress) external {
    require(msg.sender == valueDeclaratorUpdater, "sender should be current valueDeclaratorUpdater");
    valueDeclarator = _newAddress;
  }

  /**
  * @dev The changeValueDeclaratorUpdater function lets the valueDeclaratorUpdater his address.
  * @param _newAddress the new valueDeclaratorUpdater address
  * @notice This function can only be called by the current valueDeclaratorUpdater address.
  **/
  function changeValueDeclaratorUpdater(address _newAddress) external {
    require(msg.sender == valueDeclaratorUpdater, "sender should be current valueDeclaratorUpdater");
    valueDeclaratorUpdater = _newAddress;
  }

  /**
  * @dev The changeValueValidator function lets the valueValidator his address.
  * @param _newAddress the new valueValidator address
  * @notice This function can only be called by the current valueValidator address.
  **/
  function changeValueValidator(address _newAddress) external {
    require(msg.sender == valueValidator, "sender should be current valueValidator");
    valueValidator = _newAddress;
  }

  /**
  * @dev The changeRecipient0 function lets recipient0 change its address.
  * @param _newAddress the new recipient0 address
  * @notice This function can only be called by the current recipient0 address.
  **/
  function changeRecipient0(address _newAddress) external {
    require(msg.sender == recipient0, "sender should be recipient0");
    recipient0 = _newAddress;
  }

  /**
  * @dev The changeRecipient1 function lets recipient1 change its address.
  * @param _newAddress the new recipient1 address
  * @notice This function can only be called by the current recipient1 address.
  **/
  function changeRecipient1(address _newAddress) external {
    require(msg.sender == recipient1, "sender should be recipient1");
    recipient1 = _newAddress;
  }
}
