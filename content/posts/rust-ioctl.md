+++
title = 'Rust and ioctl'
date = 2025-03-18T22:23:00
tags = ['rust', 'ioctl', 'audio', 'oss']
+++


When I explore new programming language, I like to poke audio. Rust is a new language for me and I
need a pet project to learn. As I'm also using FreeBSD, that means audio device configuration is
done via `ioctl`. Here is the summary of how to handle `ioctl` in Rust. Create the project, add
`nix` crate enabling `ioctl` feature.

```sh
$ cargo new oss
$ cd oss
$ cargo add --features ioctl nix
```

For now I will just exclude `AudioInfo` from the code and show you the rest. The following is an
example of how to handle two `ioctl` calls in Rust. One writes integer and one reads structure.
Ignore for now that logicaly, setting channels before getting information about hardware is wrong.
I wanted to show `i32` version first, struct later.

```rust
use nix::libc;
use std::fs;
use std::os::fd::AsRawFd;

const SNDCTL_DSP_MAGIC: u8 = b'P';
const SNDCTL_DSP_CHANNELS: u8 = 6;
nix::ioctl_readwrite!(oss_channels, SNDCTL_DSP_MAGIC, SNDCTL_DSP_CHANNELS, i32);


const SNDCTL_INFO_MAGIC: u8 = b'X';
const SNDCTL_ENGINEINFO: u8 = 12;
nix::ioctl_readwrite!(
    oss_audio_info,
    SNDCTL_INFO_MAGIC,
    SNDCTL_ENGINEINFO,
    AudioInfo
);

fn main() {
    let devpath = String::from("/dev/dsp");
    let dsp = fs::File::open(devpath).unwrap();
    let fd = dsp.as_raw_fd();
    let mut channels: i32 = 2;
    let mut audio_info = AudioInfo::new();
    unsafe {
        oss_channels(fd, &mut channels).expect("Failed to set number of channels");
        oss_audio_info(fd, &mut audio_info).expect("Failed to get info on device");
    }
    println!("channels = {}", audio_info.max_channels);
    println!("rate = {}", audio_info.max_rate);
}
```

Let's just concentrate on the three lines after `use` block. How did I know what values to use? For
start you have to look in `/usr/src/sys/sys/soundcard.h` (assuming that's where your FreeBSD source
tree is). Let's take a look.

```c
#define SOUND_PCM_WRITE_CHANNELS	_IOWR('P', 6, int)
#define SNDCTL_DSP_CHANNELS	SOUND_PCM_WRITE_CHANNELS
```

As the call is `_IOWR` I know I have to use `ioctl_readwrite` macro, and it's obvious where `P` and
`6` come from. As the third argument to `_IOWR` is `int` I know I have to use `i32` as fourth
argument to `ioctl_readwrite`. Also, the first argument to that macro is the function name that is
generated and used later in the code.

For getting information about underlaying hardware, OSS uses `ioctl` with a struct. Let's see how
it's defined in the FreeBSD source

```c
#define SNDCTL_ENGINEINFO	_IOWR('X',12, oss_audioinfo)
```

From this I know I have to use `ioctl_readwrite`, `X` for MAGIC number and `12` for the argument.
The last one is to figure out how to work with the struct `oss_audioinfo`. Here's that structure.

```c
typedef char oss_longname_t[64];
typedef char oss_label_t[16];
typedef char oss_devnode_t[32];

typedef struct oss_audioinfo
{
    int	 dev;
    char name[64];
    int  busy;
    int  pid;
    int  caps;
    int  iformats;
    int  oformats;
    int	 magic;
    char cmd[64];
    int  card_number;
    int  port_number;
    int  mixer_dev;
    int  legacy_device;
    int  enabled;
    int  flags;
    int  min_rate;
    int  max_rate;
    int  min_channels;
    int  max_channels;
    int  binding;
    int  rate_source;
    char handle[32];
    unsigned int nrates;
    unsigned int rates[20];
    oss_longname_t song_name;
    oss_label_t label;
    int  latency;
    oss_devnode_t devnode;
    int  next_play_engine;
    int  next_rec_engine;
    int  filler[184];
} oss_audioinfo;
```

The trick in Rust is to use `#[repr(C)]`, `libc::c_int` and other `libc::c_*` types. If you put
this right below `use` block, you have the whole code.

```rust
#[repr(C)]
struct AudioInfo {
    pub dev: libc::c_int,
    pub name: [libc::c_char; 64],
    pub busy: libc::c_int,
    pub pid: libc::c_int,
    pub caps: libc::c_int,
    pub iformats: libc::c_int,
    pub oformats: libc::c_int,
    pub magic: libc::c_int,
    pub cmd: [libc::c_char; 64],
    pub card_number: libc::c_int,
    pub port_number: libc::c_int,
    pub mixer_dev: libc::c_int,
    pub legacy_device: libc::c_int,
    pub enabled: libc::c_int,
    pub flags: libc::c_int,
    pub min_rate: libc::c_int,
    pub max_rate: libc::c_int,
    pub min_channels: libc::c_int,
    pub max_channels: libc::c_int,
    pub binding: libc::c_int,
    pub rate_source: libc::c_int,
    pub handle: [libc::c_char; 32],
    pub nrates: libc::c_uint,
    pub rates: [libc::c_uint; 20],
    pub song_name: [libc::c_char; 64],
    pub label: [libc::c_char; 16],
    pub latency: libc::c_int,
    pub devnode: [libc::c_char; 32],
    pub next_play_engine: libc::c_int,
    pub next_rec_engine: libc::c_int,
    pub filler: [libc::c_int; 184],
}
```

Although nobody can give you formula on how to write ioctl code in Rust based on C but there are
some guidelines. Based on C code, you can tell which macro it uses so here's a rough table.

|   C   |     Rust        |
|-------|-----------------|
| _IO   | ioctl_none      |
| _IOR  | ioctl_read      |
| _IOW  | ioctl_write_*   |
| _IOWR | ioctl_readwrite |

For a list of `ioctl_write_*` macros and full documentation refer to
https://docs.rs/nix/latest/nix/sys/ioctl. I have to say it is easy to dive into something like this
when you have [one of the Rust advocates in FreeBSD](https://lists.freebsd.org/archives/freebsd-hackers/2024-January/002823.html)
as a work colleague, as he was really quick to spot my errors and generally guide me to a working
code as a newbie Rustacean.
