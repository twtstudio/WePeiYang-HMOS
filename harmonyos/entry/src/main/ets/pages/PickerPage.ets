import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct PickerPage {
  private context = getContext(this) as common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    await this.openPicker();
  }

  async openPicker(): Promise<void> {
    let uris: string[] = [];
    try {
      // Try photoAccessHelper.PhotoViewPicker (non-deprecated API)
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const options = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 3;
      const res = await photoPicker.select(options);
      uris = res.photoUris as string[];
    } catch (e) {
      console.error('PickerPage', 'photoAccessHelper picker failed: ' + JSON.stringify(e));
    }

    // Copy to temp dir even if no uris (will return empty)
    const tempDir = this.context.cacheDir + '/picker_temp';
    await fileIo.mkdir(tempDir, true);
    const finalPaths: string[] = [];
    for (let i = 0; i < uris.length; i++) {
      try {
        const srcFile = await fileIo.open(uris[i], fileIo.OpenMode.READ_ONLY);
        const ext = uris[i].split('.').pop() || 'jpg';
        const dstPath = tempDir + '/img_' + i + '_' + Date.now() + '.' + ext;
        const dstFile = await fileIo.open(dstPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
        await fileIo.copyFile(srcFile.fd, dstFile.fd);
        await fileIo.close(srcFile);
        await fileIo.close(dstFile);
        finalPaths.push(dstPath);
      } catch (copyErr) {
        console.error('PickerPage', 'copy ' + i + ' failed: ' + JSON.stringify(copyErr));
      }
    }

    const abilityResult: common.AbilityResult = {
      resultCode: uris.length > 0 ? 0 : -1,
      want: {
        bundleName: this.context.applicationInfo.name,
        abilityName: 'PickerAbility',
        parameters: { result: JSON.stringify(finalPaths) },
      },
    };
    this.context.terminateSelfWithResult(abilityResult);
  }

  build() {
    Column() {
      Text('正在打开相册...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
