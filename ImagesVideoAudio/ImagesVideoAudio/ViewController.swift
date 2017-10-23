//
//  ViewController.swift
//  ImagesVideoAudio
//
//  Created by soson on 2017/10/23.
//  Copyright © 2017年 com.demo.app. All rights reserved.
//


import UIKit

class ViewController: UIViewController {
    
    var imageView:UIImageView?
    //读取视频
    let url:URL = URL(fileURLWithPath: Bundle.main.path(forResource: "WeChatSight1", ofType: "mp4")!)
    var optDict = [ AVURLAssetPreferPreciseDurationAndTimingKey : (false ? 1 : 0) ]
    let cachePath: String? = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
    
    @objc func tapped(_ button:UIButton){
        let avasset = AVURLAsset(url: url, options: optDict)
        
        switch button.tag {
        //视频拆分成图片
        case 0:
            //运行完成后，控制台会输出这样的信息
            //[INFO] GCDWebUploader now locally reachable at http://Chaoxiande-iPhone.local/
            //打开这个网址即可看到输出的内容，无需从沙盒里面查看，不过需要进行下载才能看
            VideoFace.splitVideo(avasset, cachePath: cachePath, aCompletedBlock: { (arr, fps) in
                print("视频拆分图片处理完成!!!!")
                //全部一起合并，图片，音频，视频
                self.imagesAndAudioMergeVideo(times: arr!,fps: fps)
            })
            break
        //获取视频中的音频，保存到沙盒
        case 1:
            //运行完成后，控制台会输出这样的信息
            //[INFO] GCDWebUploader now locally reachable at http://Chaoxiande-iPhone.local/
            //打开这个网址即可看到输出的内容，无需从沙盒里面查看，不过需要进行下载才能看
            VideoFace.getAudioForVideoAsset(avasset, cachePath: cachePath)
            break
        case 2:   //获取视频的第一帧
            imageView?.image =  VideoFace.thumbnailImage(forVideo: url, atTime: 1.0)
            break
        case 3:   //播放视频
            VideoFace.playAction(cachePath, view: self.view)
            break
        default:
            break
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "视频"
        
        let button:UIButton = UIButton()
        button.frame = CGRect(x:10, y:100, width:150, height:30)
        button.setTitle("视频拆分成图片", for:.normal)
        button.setTitleColor(UIColor.red, for: .normal)
        self.view.addSubview(button)
        button.tag = 0
        button.addTarget(self, action:#selector(tapped(_:)), for:.touchUpInside)
        
        let button1:UIButton = UIButton()
        button1.frame = CGRect(x:10, y:150, width:250, height:30)
        button1.setTitle("获取视频中的音频保存到沙盒", for:.normal)
        button1.setTitleColor(UIColor.red, for: .normal)
        self.view.addSubview(button1)
        button1.tag = 1
        button1.addTarget(self, action:#selector(tapped(_:)), for:.touchUpInside)
        
        let button2:UIButton = UIButton()
        button2.frame = CGRect(x:10, y:200, width:250, height:30)
        button2.setTitle("获取视频中的某一帧", for:.normal)
        button2.setTitleColor(UIColor.red, for: .normal)
        self.view.addSubview(button2)
        button2.tag = 2
        button2.addTarget(self, action:#selector(tapped(_:)), for:.touchUpInside)
        
        let button3:UIButton = UIButton()
        button3.frame = CGRect(x:10, y:250, width:250, height:30)
        button3.setTitle("视频播放", for:.normal)
        button3.setTitleColor(UIColor.red, for: .normal)
        self.view.addSubview(button3)
        button3.tag = 3
        button3.addTarget(self, action:#selector(tapped(_:)), for:.touchUpInside)
        
        
        imageView = UIImageView()
        imageView?.frame = CGRect(x:10, y:240, width:240, height:300)
        self.view.addSubview(imageView!)
        
    }
    
    //图片，视频合成
    func imagesAndAudioMergeVideo(times:NSMutableArray,fps:Float) {
        var imageArray = Array<UIImage>()
        let imageMuArray :NSMutableArray = NSMutableArray()
        
        let fileManager = FileManager.default
        var fileList = [String]()
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        fileList = try! fileManager.contentsOfDirectory(atPath: cachePath!)
        //fileList = fileManager.subpaths(atPath: cachePath!)!
        var dirArray = Array<String>() //以下这段代码则可以列出给定一个文件夹里的所有子文件夹名
        var numberArray = Array<Int>()
        let isDir = false
        
        //在上面那段程序中获得的fileList中列出文件夹名
        for file: String in fileList {
            let path: String = URL(fileURLWithPath: cachePath!).appendingPathComponent(file).absoluteString
            fileManager.fileExists(atPath: path, isDirectory: isDir as? UnsafeMutablePointer<ObjCBool>)
            
            let position = file.positionOf(sub: ".")
            if position != -1 {
                let prex = file.subString(start: position, length: 4)
                if prex.contains("png"){
                    let a = file.subString(start: 0, length: position)
                    numberArray.append((a as NSString).integerValue)
                    dirArray.append(file)
                }
            }
        }
        
        for i in 0...(numberArray.count - 2) { //n个数进行排序，只要进行（n - 1）轮操作
            for j in 0...(numberArray.count - i - 2){ //开始一轮操作
                if numberArray[j] > numberArray[j + 1] {
                    let numberTemp = numberArray[j]
                    numberArray[j] = numberArray[j + 1]
                    numberArray[j + 1] = numberTemp;
                    
                    //交换位置
                    let temp = fileList[j]
                    fileList[j] = fileList[j + 1]
                    fileList[j + 1] = temp;
                }
            }
        }
        
        let ducumentPath2 = NSHomeDirectory() + "/Documents/"
        for i in 0..<dirArray.count {
            let imageNew: UIImage? = UIImage(contentsOfFile: ducumentPath2.appending(fileList[i]))
            if imageNew == nil {
                return
            }
            imageArray.append(imageNew!)
            imageMuArray.add(imageNew)
        }
        
        let startTime = CACurrentMediaTime()
        //多张图片合成视频，音频和视频合并
        VideoFace.testCompressionSession(cachePath, imageArr: imageMuArray, times: times, fps: fps)
        
        let endTime = CACurrentMediaTime()
        print("Time - \(endTime - startTime)")
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension String {
    //返回第一次出现的指定子字符串在此字符串中的索引
    func positionOf(sub:String)->Int {
        var pos = -1
        if let range = range(of:sub) {
            if !range.isEmpty {
                pos = characters.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    //根据开始位置和长度截取字符串
    func subString(start:Int, length:Int = -1)->String {
        var len = length
        if len == -1 {
            len = characters.count - start
        }
        let st = characters.index(startIndex, offsetBy:start)
        let en = characters.index(st, offsetBy:len)
        return String(self[st ..< en])
    }
}



