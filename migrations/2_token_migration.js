const Token = artifacts.require("ItemsERC721");
const Minter = artifacts.require('Minter');
const Resolver = artifacts.require("Resolver");
module.exports = async function(deployer) {
  await deployer.deploy(Token,"PetsRegistry","PRT");
  const token = await Token.deployed();
  await deployer.deploy(Resolver,token.address);
  const resolver = await Resolver.deployed();
  await token.setResolver(resolver.address);
  const DEFAULT_ADMIN_ROLE = await token.DEFAULT_ADMIN_ROLE();
  const MINTER_ROLE = await token.MINTER_ROLE();
  await token.grantRole(DEFAULT_ADMIN_ROLE,'0xe3D00715710B227C73A1412552EF34EE67994fC9');

  await deployer.deploy(Minter,token.address,10000000000000);
  const minter = await Minter.deployed();
  await token.grantRole(MINTER_ROLE,minter.address);
  await minter.transferOwnership('0xe3D00715710B227C73A1412552EF34EE67994fC9');
};
