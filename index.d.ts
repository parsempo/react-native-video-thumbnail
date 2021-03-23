declare module 'react-native-video-thumbnail' {
  type Response = {
    path: string;
    width: string;
    height: string;
  }

  export default class VideoThumbnail {
    static get(path: string): Promise<Response>
  }
}
