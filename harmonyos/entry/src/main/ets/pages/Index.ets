import common from '@ohos.app.ability.common';
import { FlutterPage } from '@ohos/flutter_ohos'
import { PhotoPickerComponent, PickerController, PickerOptions } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { resolvePickerResult } from '../entryability/EntryAbility';
import { WebPage } from './WebPage';

let storage = LocalStorage.getShared()
const EVENT_BACK_PRESS = 'EVENT_BACK_PRESS'

@CustomDialog
struct PickerDialog {
  controller: CustomDialogController;
  @State selectedUris: string[] = [];
  @State pickerCtrl: PickerController = new PickerController();

  onSelect(uri: string): void {
    const idx = this.selectedUris.indexOf(uri);
    if (idx >= 0) {
      this.selectedUris.splice(idx, 1);
    } else {
      this.selectedUris.push(uri);
    }
  }

  build() {
    Column() {
      Row() {
        Button('取消').fontSize(16).fontColor('#ffffff')
          .backgroundColor('#66000000')
          .onClick(() => {
            this.controller.close();
            resolvePickerResult([]);
          })
        Blank()
        Button() {
          Text('确定(' + this.selectedUris.length + ')')
            .fontSize(16).fontColor('#ffffff')
        }
        .backgroundColor('#1976D2')
        .enabled(this.selectedUris.length > 0)
        .onClick(async () => {
          await this.processSelected(this.selectedUris);
        })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#1a1a1a')

      PhotoPickerComponent({
        pickerOptions: new PickerOptions(),
        onSelect: (uri: string): void => { this.onSelect(uri); },
        onDeselect: (uri: string): void => { this.onSelect(uri); },
        pickerController: this.pickerCtrl,
      })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('80%')
  }

  async processSelected(uris: string[]): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    const tempDir = context.cacheDir + '/picker_temp';
    await fileIo.mkdir(tempDir, true);
    const finalPaths: string[] = [];
    for (let i = 0; i < uris.length; i++) {
      try {
        const srcFile = await fileIo.open(uris[i], fileIo.OpenMode.READ_ONLY);
        const ext = uris[i].split('.').pop() || 'jpg';
        const dstPath = tempDir + '/img_' + i + '.' + ext;
        const dstFile = await fileIo.open(dstPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
        await fileIo.copyFile(srcFile.fd, dstFile.fd);
        await fileIo.close(srcFile);
        await fileIo.close(dstFile);
        finalPaths.push(dstPath);
      } catch (copyErr) {
        console.error('Index', 'copy ' + i + ' failed: ' + JSON.stringify(copyErr));
      }
    }
    this.controller.close();
    resolvePickerResult(finalPaths);
  }
}

@Entry(storage)
@Component
struct Index {
  private context = getContext(this) as common.UIAbilityContext
  @LocalStorageLink('viewId') viewId: string = "";
  @State webViewUrl: string = '';
  @State showWebView: boolean = false;

  private pickerDialog: CustomDialogController = new CustomDialogController({
    builder: PickerDialog(),
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: 0 },
  });

  aboutToAppear(): void {
    setInterval(() => {
      // Check picker signal
      const pickerSignal = AppStorage.Get<number>('navToPicker');
      if (pickerSignal != null) {
        AppStorage.Delete('navToPicker');
        this.pickerDialog.open();
      }
      // Check webview signal
      const url = AppStorage.Get<string>('webViewUrl');
      if (url != null && url.length > 0) {
        AppStorage.Delete('webViewUrl');
        this.webViewUrl = url;
        this.showWebView = true;
      }
      // Check webview back
      const back = AppStorage.Get<string>('webViewBack');
      if (back != null) {
        AppStorage.Delete('webViewBack');
        this.showWebView = false;
        this.webViewUrl = '';
      }
    }, 500);
  }

  build() {
    Stack() {
      // Flutter layer (always present)
      Column() {
        FlutterPage({ viewId: this.viewId })
      }
      .width('100%')
      .height('100%')

      // WebView overlay (shown on demand)
      if (this.showWebView) {
        WebPage({ url: this.webViewUrl })
      }
    }
    .width('100%')
    .height('100%')
  }

  onBackPress(): boolean {
    if (this.showWebView) {
      this.showWebView = false;
      this.webViewUrl = '';
      return true;
    }
    this.context.eventHub.emit(EVENT_BACK_PRESS)
    return true
  }
}
