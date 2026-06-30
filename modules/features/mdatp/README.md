# How to install

see [faq.ottogroup.com](https://faq.ottogroup.com/knowledgebase/anleitung-zum-onboarding-von-linux-in-defender-for-endpoint/) for full docs.

1. Download License (it's created by the Python script in "MicrosoftDefenderATPOnboardingLinux.zip" (step 5)) from the [faq.ottogroup.com](https://faq.ottogroup.com/knowledgebase/anleitung-zum-onboarding-von-linux-in-defender-for-endpoint/) 
   Replace the outputs in the script for a user-writable folder, then run it, then copy the license as root to the originally defined folder.
1. Install nix-mdatp
1. After successfully installing nix-mdatp, run (as root) `mdatp config passive-mode --value disabled`
1. Add a tag via (as root) `mdatp edr tag set --name GROUP --value Unmanaged_OTTO`
1. Check with `mdatp health`:
   We are looking for `healthy: true`, `licensed: true` and both `real_time_protection_enabled` and `real_time_protection_available` set to `true`. 
   Also, `passive_mode_enabled: false` is what we want. And you should see the `edr_device_tags : [{"key":"GROUP","value":"Unmanaged_OTTO"}]`.
