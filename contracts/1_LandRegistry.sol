// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./2_Properties.sol";

contract LandRegistry {
    address private contractOwner;
    address private transferOwnershipContractAddress;
    bool private transferOwnershipContractAddressUpdated;

    Property public propertiesContract;

    constructor() {
        contractOwner = msg.sender;
        transferOwnershipContractAddress = address(0);
        transferOwnershipContractAddressUpdated = false;

        propertiesContract = new Property();
    }

    // modifiers

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only Contract onwner can access");
        _;
    }

    modifier onlyAdmin(uint256 _adminId) {
        require(
            msg.sender == adminIdToAddress[_adminId],
            "Only Admin can Access"
        );
        _;
    }

    event LandAdded(address indexed owner, uint256 indexed propertyId);

    // mapping owner and their properties
    mapping(address => uint256[]) private propertiesOfOwner;

    // mapping Admin and properties under control of Admin
    // for verification procedures
    mapping(uint256 => uint256[]) private propertiesControlledByAdmin;

    // mapping of AdminId to Admin address
    mapping(uint256 => address) public adminIdToAddress;

    function setTransferOwnershipContractAddress(address _contractAddress)
        public
    {
        require(
            transferOwnershipContractAddressUpdated == false,
            "Only Allowed to call Once"
        );
        transferOwnershipContractAddress = _contractAddress;
        transferOwnershipContractAddressUpdated = true;
    }

    function addLand(
        uint256 _locationId,
        uint256 _adminId,
        uint256 _surveyNumber,
        uint256 _area
    ) public returns (uint256) {
        address _owner = msg.sender;
        uint256 propertyId = propertiesContract.addLand(
            _locationId,
            _adminId,
            _surveyNumber,
            _owner,
            _area
        );
        propertiesOfOwner[_owner].push(propertyId);
        propertiesControlledByAdmin[_adminId].push(propertyId);
        emit LandAdded(_owner, propertyId);
        return propertyId;
    }

    function getPropertyDetails(uint256 _propertyId)
        public
        view
        returns (Property.Land memory)
    {
        return propertiesContract.getLandDetailsAsStruct(_propertyId);
    }

    function getPropertiesOfOwner(address _owner)
        public
        view
        returns (Property.Land[] memory)
    {
        uint256[] memory propertyIds = propertiesOfOwner[_owner];
        Property.Land[] memory properties = new Property.Land[](
            propertyIds.length
        );

        for (uint256 i = 0; i < propertyIds.length; i++) {
            properties[i] = propertiesContract.getLandDetailsAsStruct(
                propertyIds[i]
            );
        }
        return properties;
    }

    function getPropertiesByAdminId(uint256 _adminId)
        public
        view
        returns (Property.Land[] memory)
    {
        uint256[] memory propertyIds = propertiesControlledByAdmin[_adminId];

        Property.Land[] memory properties = new Property.Land[](
            propertyIds.length
        );

        for (uint256 i = 0; i < propertyIds.length; i++) {
            properties[i] = propertiesContract.getLandDetailsAsStruct(
                propertyIds[i]
            );
        }

        return properties;
    }

    function mapAdminIdToAddress(uint256 _adminId, address _adminAddress)
        public
        onlyOwner
    {
        adminIdToAddress[_adminId] = _adminAddress;
    }

    function getAdminId(uint256 propertyId) private view returns (uint256) {
        return propertiesContract.getLandDetailsAsStruct(propertyId).adminId;
    }

    function verifyProperty(uint256 _propertyId)
        public
        onlyAdmin(getAdminId(_propertyId))
    {
        propertiesContract.changeStateToVerifed(_propertyId, msg.sender);
    }

    function rejectProperty(uint256 _propertyId, string memory _reason)
        public
        onlyAdmin(getAdminId(_propertyId))
    {
        propertiesContract.changeStateToRejected(
            _propertyId,
            msg.sender,
            _reason
        );
    }

    function transferOwnership(uint256 _propertyId, address _newOwner) public {
        require(
            msg.sender == transferOwnershipContractAddress,
            "Only TransferOfOwnerShip Contract Allowed"
        );
        address oldOwner = propertiesContract
            .getLandDetailsAsStruct(_propertyId)
            .owner;

        uint256[] storage propertiesOfOldOwner = propertiesOfOwner[oldOwner];
        for (uint256 i = 0; i < propertiesOfOldOwner.length; i++) {
            if (propertiesOfOldOwner[i] == _propertyId) {
                propertiesOfOldOwner[i] = propertiesOfOldOwner[
                    propertiesOfOldOwner.length - 1
                ];
                propertiesOfOldOwner.pop();
                break;
            }
        }
        propertiesOfOwner[_newOwner].push(_propertyId);

        propertiesContract.updateOwner(_propertyId, _newOwner);
    }

    function getPropertiesContract() public view returns (address) {
        return address(propertiesContract);
    }
}
