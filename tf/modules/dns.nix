{ lib, ... }:

let
  dnsSubmodule =
    { name, ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          defaultText = lib.literalExpression "<name>";
        };

        content = lib.mkOption {
          type = lib.types.str;
        };

        type = lib.mkOption {
          type = lib.types.str;
        };
      };
    };

  domainSubmodule =
    { name, ... }:
    {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
        defaultText = lib.literalExpression "<name>";
      };

      records = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule dnsSubmodule);
        default = { };
      };
    };
in

{
  # Provider-agnostic DNS interface
  options.borealis.dns = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule domainSubmodule);
    default = { };
    description = "Attribute set of domains and their corresponding DNS records.";
  };
}
