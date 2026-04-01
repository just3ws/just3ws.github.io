# Task-010: Image Optimization

**Status:** To Do
**Priority:** Low

## Description
There is currently no image optimization in the build pipeline. Large assets like `avatar.png` and video thumbnails are served at their original size, which can impact site performance.

## Acceptance Criteria
- [ ] Implement image optimization during the build.
- [ ] Compression for PNG and JPEG files using tools like `image_optim` or `mini_magick`.
- [ ] Generation of responsive images (e.g., `srcset`) if possible within Jekyll.
- [ ] Verify that optimized images maintain acceptable quality.
