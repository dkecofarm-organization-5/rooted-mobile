# ROOTED Font Setup

RC8.6 is designed to use **Pretendard Variable v1.3.9** as the embedded local body font.

Expected local file:
`assets/fonts/PretendardVariable.woff2`

The font binary is not included in this handoff package.
Run the top-level script:

`PREPARE_ROOTED_FONTS.cmd`

while connected to the internet. It downloads the official Pretendard Variable WOFF2 into this folder. After that, the digital storybook uses the local file and does not require internet for typography.

If the font file is absent, the player falls back to system fonts, so final typography acceptance should only be performed after this setup is complete.
