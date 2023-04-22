{ super, src, ... }:
{ pkgs, ... }: {
  imports = map (x: x.default) (
    with src; [
      clash
      common
      extlinux
      openfortivpn
      qinglong
      smartdns
      users
    ]
  );

  documentation.man.enable = false;
}
