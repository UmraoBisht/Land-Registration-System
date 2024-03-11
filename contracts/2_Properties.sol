// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Property {
    enum StateOfProperty {
        Created,
        Scheduled,
        Verified,
        Rejected,
        OnSale,
        Bought
    }

    struct Land {
        uint256 propertyId;
        uint256 locationId;
        uint256 adminId;
        uint256 surveyNumber;
        address owner;
        uint256 area;
        uint256 price;
        uint256 registeredTime;
        address adminAddress;
        string scheduledDate;
        string rejectedReason;
        StateOfProperty state;
    }

    mapping(uint256 => Land) public lands;
    uint256 private landCount;

    function addLand(
        uint256 _locationId,
        uint256 _adminId,
        uint256 _surveyNumber,
        address _owner,
        uint256 _area
    ) public returns (uint256) {
        landCount++;
        lands[landCount] = Land({
            propertyId: landCount,
            locationId: _locationId,
            adminId: _adminId,
            surveyNumber: _surveyNumber,
            owner: _owner,
            area: _area,
            price: 0,
            registeredTime: block.timestamp,
            adminAddress: address(0),
            scheduledDate: "",
            rejectedReason: "",
            state: StateOfProperty.Created
        });
        return landCount;
    }

    function getLandDetailsAsStruct(uint256 _propertyId)
        public
        view
        returns (Land memory)
    {
        require(lands[_propertyId].propertyId != 0, "Land does not exist");

        return (
            Land({
                propertyId: _propertyId,
                locationId: lands[_propertyId].locationId,
                adminId: lands[_propertyId].adminId,
                surveyNumber: lands[_propertyId].surveyNumber,
                owner: lands[_propertyId].owner,
                area: lands[_propertyId].area,
                price: lands[_propertyId].price,
                registeredTime: lands[_propertyId].registeredTime,
                adminAddress: lands[_propertyId].adminAddress,
                scheduledDate: lands[_propertyId].scheduledDate,
                rejectedReason: lands[_propertyId].rejectedReason,
                state: lands[_propertyId].state
            })
        );
    }

    function removeLand(uint256 _propertyId) public {
        require(lands[_propertyId].propertyId != 0, "Land does not exist");
        delete lands[_propertyId];
    }

    function updateLand(
        uint256 _propertyId,
        uint256 _locationId,
        uint256 _adminId,
        uint256 _surveyNumber,
        address _owner,
        uint256 _area,
        address _adminAddress,
        string memory _scheduledDate,
        string memory _rejectedReason,
        StateOfProperty _state
    ) public {
        require(lands[_propertyId].propertyId != 0, "Land does not exist");

        lands[_propertyId].locationId = _locationId;
        lands[_propertyId].adminId = _adminId;
        lands[_propertyId].surveyNumber = _surveyNumber;
        lands[_propertyId].owner = _owner;
        lands[_propertyId].area = _area;
        lands[_propertyId].adminAddress = _adminAddress;
        lands[_propertyId].scheduledDate = _scheduledDate;
        lands[_propertyId].rejectedReason = _rejectedReason;
        lands[_propertyId].state = _state;
    }

    function changeStateToVerifed(uint256 _propertyId, address _adminAddress)
        public
    {
        require(lands[_propertyId].propertyId != 0, "Land does not exist");
        lands[_propertyId].adminAddress = _adminAddress;
        lands[_propertyId].state = StateOfProperty.Verified;
    }

    function changeStateToRejected(
        uint256 _propertyId,
        address _adminAddress,
        string memory _reason
    ) public {
        require(lands[_propertyId].propertyId != 0, "Land does not exist");

        lands[_propertyId].adminAddress = _adminAddress;
        lands[_propertyId].state = StateOfProperty.Rejected;
        lands[_propertyId].rejectedReason = _reason;
    }

    function changeStateToOnSale(uint256 _propertyId, address _owner) public {
        require(lands[_propertyId].propertyId != 0, "Land does not exist");
        require(
            lands[_propertyId].owner == _owner,
            "only owner can make available to sell"
        );
        lands[_propertyId].state = StateOfProperty.OnSale;
    }

    function changeStateBackToVerified(uint256 _propertyId, address _owner)
        public
    {
        require(lands[_propertyId].propertyId != 0, "Land does not exist");
        require(
            lands[_propertyId].owner == _owner,
            "Only Owner of This Land is Allowed to Change State to Verified"
        );
        lands[_propertyId].state = StateOfProperty.Verified;
    }

    function updateOwner(uint256 _propertyId, address _newOwner) public {
        require(lands[_propertyId].propertyId != 0, "Land does not exist");
        lands[_propertyId].owner = _newOwner;
        lands[_propertyId].state = StateOfProperty.Bought;
    }
}
