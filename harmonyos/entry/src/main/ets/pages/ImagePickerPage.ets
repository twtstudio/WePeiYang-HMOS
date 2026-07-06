import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import router from '@ohos.router';

@Entry
@Component
struct ImagePickerPage {
  private context = getContext(this) as common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    await this.openPicker();
  }

  async openPicker(): Promise<void> {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const options = new picker.PhotoSelectOptions();
      options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 3;
      const res = await photoPicker.select(options);
      const uris: string[] = res.photoUris as string[];

      // Copy to app cache dir so Flutter can read
      const tempDir = this.context.cacheDir + '/picker_temp';
      await fileIo.mkdir(tempDir, true);
      const resultPaths: string[] = [];
      for (let i = 0; i < uris.length; i++) {
        try {
          const srcFile = await fileIo.open(uris[i], fileIo.OpenMode.READ_ONLY);
          const ext = uris[i].split('.').pop() || 'jpg';
          const dstPath = tempDir + '/img_' + i + '.' + ext;
          const dstFile = await fileIo.open(dstPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
          await fileIo.copyFile(srcFile.fd, dstFile.fd);
          await fileIo.close(srcFile);
          await fileIo.close(dstFile);
          resultPaths.push(dstPath);
        } catch (copyErr) {
          console.error('ImagePickerPage', 'copy ' + i + ' failed: ' + JSON.stringify(copyErr));
        }
      }

      // Store paths in AppStorage for Flutter to retrieve
      AppStorage.Set('pickerResult', JSON.stringify(resultPaths));
    } catch (e) {
      console.error('ImagePickerPage', 'openPicker failed: ' + JSON.stringify(e));
      AppStorage.Set('pickerResult', '[]');
    }

    // Go back to FlutterPage
    router.back();
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
