def main(ctx):
  publish = ctx.build.branch == "master"
  return [
    step("amd64", publish),
    step("arm64", publish),
  ]

def step(arch, publish):
  pipeline = {
    "kind": "pipeline",
    "name": "build-%s" % arch,
    "platform": {
      "os": "linux",
      "arch": arch,
    },
    "workspace": {
      "path": "mono/src",
    },
    "steps": [
      {
        "name": "build",
        "image": "spritsail/abuild:edge",
        "pull": "always",
        "privileged": True,
        "settings": {
          "publickey": "https://alpine.spritsail.io/spritsail-alpine.rsa.pub",
        },
        "environment": {
          "SIGNINGKEY": {
            "from_secret": "signingkey",
          },
        },
      },
    ],
  }
  if publish:
    pipeline["steps"][0]["settings"]["repo_sshfs"] = "drone-upload@web.spritsail.io:"
    pipeline["steps"][0]["environment"]["SSHKEY"] = {"from_secret": "sshkey"}

  return pipeline

# vim: ft=python sw=2
