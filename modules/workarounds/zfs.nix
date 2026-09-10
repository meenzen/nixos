{
  pkgs,
  config,
  ...
}: {
  # fix zfs performance issue
  # see https://github.com/NixOS/nixpkgs/issues/363068#issuecomment-5498857727
  nixpkgs.overlays = [
    (_: prev: {
      kernelPackagesExtensions =
        prev.kernelPackagesExtensions
        ++ [
          # https://github.com/NixOS/nixpkgs/blob/5dfba6236110080a54247d6460bc2ff5dda939cc/pkgs/top-level/linux-kernels.nix#L668
          (
            _: prev: let
              pkgName = config.boot.zfs.package.kernelModuleAttribute; # https://github.com/NixOS/nixpkgs/blob/fd1462031fdee08f65fd0b4c6b64e22239a77870/nixos/modules/tasks/filesystems/zfs.nix#L22
            in {
              ${pkgName} = prev.${pkgName}.overrideAttrs (prev: {
                patches =
                  prev.patches
                  ++ [
                    (pkgs.writeText "https://github.com/openzfs/zfs/issues/11140#issuecomment-5498519538" ''
                      diff --git a/module/os/linux/zfs/zpl_inode.c b/module/os/linux/zfs/zpl_inode.c
                      index 3492f4a..37caaab 100644
                      --- a/module/os/linux/zfs/zpl_inode.c
                      +++ b/module/os/linux/zfs/zpl_inode.c
                      @@ -279,6 +279,7 @@ zpl_mknod(struct inode *dir, struct dentry *dentry, umode_t mode,
                       	return (error);
                       }

                      +#if 0
                       static int
                       #ifdef HAVE_TMPFILE_IDMAP
                       zpl_tmpfile(struct mnt_idmap *userns, struct inode *dir,
                      @@ -347,6 +348,7 @@ zpl_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)

                       	return (error);
                       }
                      +#endif

                       static int
                       zpl_unlink(struct inode *dir, struct dentry *dentry)
                      @@ -851,7 +853,6 @@ const struct inode_operations zpl_dir_inode_operations = {
                       	.rmdir		= zpl_rmdir,
                       	.mknod		= zpl_mknod,
                       	.rename		= zpl_rename,
                      -	.tmpfile	= zpl_tmpfile,
                       	.setattr	= zpl_setattr,
                       	.getattr	= zpl_getattr,
                       	.listxattr	= zpl_xattr_list,
                    '')
                  ];
              });
            }
          )
        ];
    })
  ];
}
