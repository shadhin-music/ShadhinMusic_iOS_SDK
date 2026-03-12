//
//  HomeAdaptar.swift
//  ShadhinStory
//
//  Created by Maruf on 14/12/23.
//
import UIKit



enum  RewindPatchType: CaseIterable {
    case CELL_TYPE_ONE
    case CELL_TYPE_TWO
    case CELL_TYPE_THREE
    case CELL_TYPE_FOUR
    case CELL_TYPE_FIVE
    case CELL_TYPE_SIX
    case CELL_TYPE_SEVEN
    
}

class RewindAdapter: NSObject {
    private var streamingDataSource : [TopStreammingElementModel] = []
    private var dataSource : [RewindPatchType] = RewindPatchType.allCases
    
    func addPatches(array: [TopStreammingElementModel]){
        streamingDataSource.append(contentsOf: array)
    }
}

extension RewindAdapter : FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        dataSource.count
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let patchType  = dataSource[index]
        switch patchType {
        case .CELL_TYPE_ONE:
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: StoryShareStepCellOne.identifier, at: index) as! StoryShareStepCellOne
            return cell
        case .CELL_TYPE_TWO:
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: StoryShareStepCellTwo.identifier, at: index) as! StoryShareStepCellTwo
            
            return cell
        case .CELL_TYPE_THREE:
            guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: StoryShareStepCellThree.identifier, at: index) as? StoryShareStepCellThree else {
                fatalError()
            }
            let dataArray = streamingDataSource.filter({$0.contentType == "TotalPlayCount"})
            if !dataArray.isEmpty {
                cell.timeSpentLabel.text = "\(dataArray[0].minOfStream ?? 0) \("minutes")"
            }
            return cell
        case .CELL_TYPE_FOUR:
            guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: StoryShareStepCellFour.identifier, at:index) as? StoryShareStepCellFour else{
                fatalError()
            }
            let dataArray = streamingDataSource.filter({$0.contentType == "Artist"})
            let artistImageArray = streamingDataSource.filter({$0.contentType == "Artist"})
            if !dataArray.isEmpty || !artistImageArray.isEmpty {
                cell.bindData(artists: dataArray)
                cell.bindArtistImage(artists: artistImageArray)
            }
            return cell
        case .CELL_TYPE_FIVE:
            guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: StoryShareStepCellFive.identifier, at:index) as? StoryShareStepCellFive else{
                fatalError()
            }
            let dataArray = streamingDataSource.filter({$0.contentType == "Song"})
            let imageArray = streamingDataSource.filter({$0.contentType == "Song"})
            if !dataArray.isEmpty  || !imageArray.isEmpty {
                cell.bindTopSong(songs: dataArray)
                cell.bindTopImage(songs: imageArray)
            }
            return cell
        case .CELL_TYPE_SIX:
            guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: StoryShareStepCellSix.identifier, at:index) as? StoryShareStepCellSix else{
                fatalError()
            }
            let dataArray = streamingDataSource.filter({$0.contentType == "Podcast"})
            let imageArray = streamingDataSource.filter({$0.contentType == "Podcast"})
            if !dataArray.isEmpty || !imageArray.isEmpty {
                cell.bindTopPodcastData(podCast: dataArray)
                cell.bindTopPodcastImage(podCast: imageArray)
            }
            return cell
        case .CELL_TYPE_SEVEN:
            guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: StoryShareStepCellSeven.identifier, at:index) as? StoryShareStepCellSeven else{
                fatalError()
            }
            let timeSpentArray = streamingDataSource.filter({$0.contentType == "TotalPlayCount"})
            let artistArray = streamingDataSource.filter({$0.contentType == "Artist"})
            let songArray = streamingDataSource.filter({$0.contentType == "Song"})
            let podCastArray = streamingDataSource.filter({$0.contentType == "Podcast"})
            if !artistArray.isEmpty || !songArray.isEmpty || !podCastArray.isEmpty || !timeSpentArray.isEmpty {
                cell.bindTopArtistData(artist: artistArray)
                cell.bindTopSongData(song: songArray)
                cell.bindTopPodcastData(podcast:podCastArray)
                cell.totalTimeSpent.text  = "\(timeSpentArray[0].minOfStream ?? 0)"
            }
            return cell
        }
    }
}
