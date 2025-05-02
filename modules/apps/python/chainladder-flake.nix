{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.python.chainladder-flake.enable = lib.mkOption {
    description = "Configure PYTHON CHAINLADDER library";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.python.chainladder-flake.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #environment.systemPackages = with pkgs; [
    #  (builtins.getFlake "github:matleborgne/chainladder-python/31cf6baf77053d3f10c1142ee4b7bfa8578368ea").packages.x86_64-linux.default
    #];



#    environment.systemPackages =
#
#      let
#        chainladderFlake = (builtins.getFlake "github:matleborgne/chainladder-python/31cf6baf77053d3f10c1142ee4b7bfa8578368ea").packages.x86_64-linux.default;
#        
#        python = pkgs.python3.override {
#          self = python;
#          packageOverrides = pyfinal: pyprev: {
#            chainladder = pyfinal.callPackage chainladderFlake {};
#          };
#        };

#      in [ (python.withPackages (python-pkgs: [ python-pkgs.chainladder ])) ];


      environment.systemPackages =

        let
          flake = builtins.getFlake "github:matleborgne/chainladder-python/31cf6baf77053d3f10c1142ee4b7bfa8578368ea";
          chainladderPkg = flake.packages.x86_64-linux.default;
          pythonEnv = pkgs.python3.withPackages (ps: [ chainladderPkg ]);

        in [ pythonEnv ];




  };
}
