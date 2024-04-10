---
name: Module requests
about: For modules that should be added in NixOS
title: 'Module request: MODULENAME'
labels: '0.kind: module request'
assignees: ''

---

**Module description**

<!-- Describe the module a little: -->

**Metadata**

* homepage URL:
* source URL:
* license: mit, bsd, gpl2+ , ...
* platforms: unix, linux, darwin, ...

**Checks**

- [ ] changes are backward compatible
- [ ] removed options are declared with `mkRemovedOptionModule`
- [ ] changes that are not backward compatible are documented in release notes
- [ ] module tests succeed on ARCHITECTURE
- [ ] options types are appropriate
- [ ] options description is set
- [ ] options example is provided
- [ ] documentation affected by the changes is updated

**Some useful resources**

* [NixOS documentation](https://github.com/NixOS/nixpkgs/blob/master/nixos/README.md)
* [How to write your NixOS module](https://github.com/NixOS/nixpkgs/blob/master/nixos/doc/manual/development/writing-modules.chapter.md)

---

Add a :+1: [reaction] to [issues you find important].

[reaction]: https://github.blog/2016-03-10-add-reactions-to-pull-requests-issues-and-comments/
[issues you find important]: https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+is%3Aopen+sort%3Areactions-%2B1-desc
