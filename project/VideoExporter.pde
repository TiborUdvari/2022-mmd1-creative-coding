// todo - get the duration of a clip example
//ffprobe -i input.mkv -show_entries format=duration -v quiet -of csv="p=0"


// duration - $(echo $(ffprobe -i out12.mkv -show_entries format=duration -v quiet -of csv="p=0") - .1 | bc)
// todo - add a 1s crossfade at the end


// ffmpeg -i out12-loop.mkv -af "afade=t=out:st=$(ffprobe -i out12.mkv -show_entries format=duration -v quiet -of csv="p=0")-1:d=1,afade=t=in:st=0:d=1" -c:a aac -c:v copy out12-cross.mkv
// echo $(echo $(ffprobe -i out12.mkv -show_entries format=duration -v quiet -of csv="p=0") - .1 | bc)

// ffmpeg -i out12-loop.mkv -af "afade=t=out:st=$(echo $(ffprobe -i out12-loop.mkv -show_entries format=duration -v quiet -of csv="p=0") - .1 | bc):d=1,afade=t=in:st=0:d=1" -c:a aac -c:v copy out12-cross.mkv


// ffmpeg -i out12-loop.mkv -af "afade=t=out:st=$(echo $(ffprobe -i out12-loop.mkv -show_entries format=duration -v quiet -of csv="p=0") - 1 | bc):d=1,afade=t=in:st=0:d=1" -c:a aac -c:v copy out12-cross.mkv
// ffmpeg -i out12-loop.mkv -vf "fade=t=in:st=0:d=1,fade=t=out:st=$(echo $(ffprobe -i out12-loop.mkv -show_entries format=duration -v quiet -of csv="p=0") - 1.5 | bc):d=1" -af "afade=t=out:st=$(echo $(ffprobe -i out12-loop.mkv -show_entries format=duration -v quiet -of csv="p=0") - 1 | bc):d=1,afade=t=in:st=0:d=1" -c:a aac out12-cross.mkv

// Perfect loop to get at least 25 seconds of video
// Apply the fades to the beginning and end

// Get the length of the video

// vid="out.mkv" && 
//duration=$(echo "25 / 0.9" | bc) && echo $duration


import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

static class VideoExporter
{
  public static String getLatestGitLog(PApplet applet) {
    ProcessBuilder processBuilder = new ProcessBuilder();
    processBuilder.directory(new File(applet.sketchPath()));
    String gitLog = "git describe --always";
    processBuilder.command("zsh", "-c", gitLog);

    try {
      Process process = processBuilder.start();

      BufferedReader reader =
        new BufferedReader(new InputStreamReader(process.getInputStream()));

      String acc = "";
      String line;
      while ((line = reader.readLine()) != null) {
        acc += line;
      }

      int exitCode = process.waitFor();
      return acc.strip();
    }
    catch (Exception e) {
      println("Catch all exception");
      println(e);
    }
    return "";
  }

  // Git commit + time
  public static String defaultFileName(PApplet applet) {
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("uuuu-MM-dd_HH-mm-ss");
    LocalDateTime now = LocalDateTime.now();
    
    return "%s-%s".formatted(dtf.format(now), VideoExporter.getLatestGitLog(applet));
  }

  public static void generateGif(PApplet applet, String fileName) {
    String png2gif = "/usr/local/bin/mogrify -format gif *.png";
    String gifsicle = "/usr/local/bin/gifsicle --delay=2 --loop *.gif > %s.gif".formatted(fileName);
    String saveRes = "mv " + fileName + ".gif temp.bak";
    String rmGif = "rm *.gif";
    String restoreRes = "mv temp.bak " + fileName + ".gif";
    String makeGif = "%s && %s && %s && %s && %s".formatted(png2gif, gifsicle, saveRes, rmGif, restoreRes);

    VideoExporter.executeCommand(applet, makeGif);
  }
  
  public static void generateVideo(PApplet applet, String fileName) {
     String makeIGLoop = "/encode-for-ig %s".formatted(fileName);
    VideoExporter.executeCommand(applet, makeIGLoop);

    // Conversions to aac
    
    // Using the native AAC codec:
    //ffmpeg -i input.wav -c:a aac -b:a 128k -loop 1 output-aac.aac

    // Using the Nero AAC codec:
    // ffmpeg -i input.wav -c:a libfdk_aac -vbr 4 output-nero.aac

    // Using the fdk-aac codec:
    // ffmpeg -i input.wav -c:a fdk-aac -vbr 3 output-fdk.aac
    
    // Test the loop
    // ffplay -loop -1 2023-02-11_16-20-25-75b44f2.mov
    /*
    String makeVideoLossless = "/usr/local/bin/ffmpeg -i image%d.png -c:v huffyuv -pix_fmt yuv444p -r 60 output.avi";
    
    String makeVideoNoSound = " /usr/local/bin/ffmpeg -y -framerate 60 -pattern_type glob -i '*.png' -preset veryslow -tune animation -c:v libx264 -pix_fmt yuv420p -crf 23 -f mp4 %s-mute.mov".formatted(fileName, fileName);
    VideoExporter.executeCommand(applet, makeVideoNoSound);
    
    // Convert sound to .aac
    // Important - use Apple alac for AAC, default encoder was adding silence at the beginning and end of the format
    String convertSoundToAAC = " /usr/local/bin/ffmpeg -i %s.wav -c:a alac %s.m4a".formatted(fileName, fileName);
    VideoExporter.executeCommand(applet, convertSoundToAAC);

    // Combine video and sound
    String combineAudioVideo = "/usr/local/bin/ffmpeg -i %s-mute.mov -i %s.m4a -c:v copy -c:a copy %s.mov".formatted(fileName, fileName, fileName);
    VideoExporter.executeCommand(applet, combineAudioVideo);
    
    // -shortest -map 0:v:0 -map 0:a:0
    
    
    //String makeAudioLoop5 = "/usr/local/bin/ffmpeg -y -stream_loop 5 -i %s.wav -c copy %s-loop05.wav".formatted(fileName, fileName);
    //VideoExporter.executeCommand(applet, makeAudioLoop5);
        
    String makeVideoLoop5 = "/usr/local/bin/ffmpeg -y -stream_loop 5 -i %s.mov -c copy %s-loop05.mov".formatted(fileName, fileName);
    VideoExporter.executeCommand(applet, makeVideoLoop5);
    
    String makeVideoLoop10 = "/usr/local/bin/ffmpeg -y -stream_loop 10 -i %s.mov -c copy %s-loop10.mov".formatted(fileName, fileName);
    VideoExporter.executeCommand(applet, makeVideoLoop10);
    */
  }
  
  public static void cleanupImages(PApplet applet, String folderName) {
    String cleanup = "mkdir -p %s && mv *.png %s".formatted(folderName, folderName);
    VideoExporter.executeCommand(applet, cleanup);
  }

  public static void executeCommand(PApplet applet, String command) {
    ProcessBuilder processBuilder = new ProcessBuilder();
    processBuilder.directory(new File(applet.sketchPath()));
    
    println("Executing command: %s".formatted(command));
    processBuilder.command("zsh", "-c", command);

    try {
      Process process = processBuilder.start();

      BufferedReader reader =
        new BufferedReader(new InputStreamReader(process.getInputStream()));

      String line;
      while ((line = reader.readLine()) != null) {
        System.out.println(line);
      }

      int exitCode = process.waitFor();

      System.out.println("\nExited with code : " + exitCode);
      if (exitCode != 0) {
        println("Failed to generate the documentation.");
      }
    }
    catch (IOException e) {
      e.printStackTrace();
    }
    catch (InterruptedException e) {
      e.printStackTrace();
    }
    catch (Exception e) {
      println("Catch all exception");
      println(e);
    }
  }
}
