# Windows 2019

This section allow you to create a packer template for Windows 2019.

## Prerequirements

Download the Windows drivers for paravirtualized KVM/QEMU hardware: [virtio-win](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)

## Creation

To create the template, run the following command:

```bash
packer build --only=qemu --var virtio_win_iso=./virtio-win.iso ./windows_2019.json
```

## Credits

Thanks to [StefanScherer](https://github.com/StefanScherer/) for its amazing repository: https://github.com/StefanScherer/packer-windows