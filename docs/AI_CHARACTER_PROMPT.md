# Character art prompt | برومبت رسوم الشخصية

Use the prompt below to generate a source sprite sheet. The runtime loads eight separate transparent PNG parts from `assets/rig/`; do not use the uncut sprite sheet as an app asset.

استخدم النص التالي لإنشاء لوحة مصدر واحدة، ثم افصلها إلى ثماني صور PNG شفافة. التطبيق يحمّل الأجزاء المنفصلة من `assets/rig/` ولا يستخدم لوحة المصدر مباشرة.

## Prompt | النص

```text
Flat 2D vector cartoon athlete character, completely faceless (smooth blank oval head, no eyes, nose or mouth),
side view facing right. Deconstructed into EIGHT SEPARATE body parts on a plain white background, laid out as a
sprite sheet with generous spacing and no overlap: head, torso (orange sports t-shirt), upper arm, forearm, hand,
thigh (dark gray shorts), shin, foot (white sneaker). Every part drawn straight and un-bent in a neutral orientation,
with a small red dot marking the joint pivot at each end. Thick clean outlines, solid flat colors, consistent style
across all parts, no shadows, no gradients, no text, square 2048x2048.
```

## Preparing the assets | تجهيز الصور

1. Crop each body part separately and remove the white background. Export as transparent RGBA PNG.
2. Save exactly these eight filenames in `assets/rig/`: `head.png`, `torso.png`, `uarm.png`, `farm.png`, `hand.png`, `thigh.png`, `shin.png`, and `foot.png`.
3. Use the red dots only as pivot guides; remove them from the final character artwork.
4. Keep each exported image at the dimensions used by `partMeta` in [`lib/parts_data.dart`](../lib/parts_data.dart): head 151×202, torso 108×260, upper arm 60×206, forearm 45×160, hand 59×110, thigh 98×240, shin 62×198, and foot 134×87 pixels.
5. The pivot coordinates in `partMeta` are measured from the image's top-left. Some pivots intentionally lie just outside the image bounds where two body parts meet. If an image is resized, trimmed, or padded, update its dimensions and pivot coordinates together.
6. Preview the character in the app after replacing art. Check the idle stance and several animation frames; change the poses or pivot metadata if joints visibly separate or parts clip.

الأبعاد أعلاه مطابقة للأصول الحالية. قصّ أو تحجيم الصور دون تحديث `partMeta` سيؤدي إلى انزياح المفاصل. النقاط الحمراء إرشادية فقط ويجب حذفها من الصور النهائية.
