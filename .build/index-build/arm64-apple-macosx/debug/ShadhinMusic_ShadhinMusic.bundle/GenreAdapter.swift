//
//  SearchAdapter.swift
//  Shadhin
//
//  Created by Maruf on 5/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

protocol SearchAdapterProtocol {
    
}

class GenreAdapter:NSObject {
    var playLists = [NewSearchPlaylist]()
    var filteredPlayLists = [NewSearchPlaylist]()
    let vc : SearchMainV3
    var searchState = SearchState.initail
    var searchTimer: Timer?
    var curretSearchTerm: String?
    var oldSearchTerm: String?
    var selectedContentType = "All"
    
    init(vc:SearchMainV3) {
        self.vc = vc
        super.init()
        newSearchGetToPlayList()
    }
    
    private func showProgressView() {
        vc.clearSearchBtn.isHidden = true
        vc.searchProgressView.isHidden = false
        vc.searchProgressView.startAnimating()
    }
    
    private func hideProgressView() {
        vc.clearSearchBtn.isHidden = false
        vc.searchProgressView.stopAnimating()
        vc.searchProgressView.isHidden = true
    }
    
    private func newSearchGetToPlayList() {
        showProgressView()
        ShadhinCore.instance.api.getToPlayList { [weak self] responseModel in
            self?.hideProgressView()
            switch responseModel {
            case .success(let data):
                self?.playLists = data.contents
                self?.vc.collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func handleSearchTabClicked(_ tabname: String) {
        selectedContentType = getContentType(tabname: tabname)
        if selectedContentType == "All" {
            guard let searchText = vc.searchTf.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
            getSearchResultForAll_Updated(searchText: searchText)
        } else {
            searchWhenContentTypeIsNotAll()
        }
    }
    
    private func getContentType(tabname: String) -> String {
        print(tabname)
        switch tabname {
        case "Artists":
            return "A"
        case "Albums":
            return "R"
        case "Tracks":
            return "S"
        case "Videos":
            return "V"
        case "Podcasts":
            return "PS"
        case "Playlists":
            return "P"
        default:
            return "All"
        }
    }
    
}

extension GenreAdapter : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard when return key is pressed
        vc.searchTf.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //txtField.leftView =
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: textField.frame.height))
        vc.txtField.leftView = paddingView
        vc.txtField.leftViewMode = .always
        vc.txtField.textAlignment = .left
        if let searchText = vc.searchTf.text, searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            demoChangeAdapter()
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //filteredPlayLists = playLists
        //vc.collectionView.reloadData()
      //  demoChangeAdapter()
    }
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // This method will be called whenever the text field's contents change
        demoChangeAdapter()
        // You can perform any additional actions you need here
    }
    
    func checkAndSetupRecentHistories(){
        ShadhinCore.instance.api.getSearchHistories_V2(userCode: ShadhinCore.instance.defaults.userIdentity) { [weak self] responseModel in
            switch responseModel {
            case .success(let data):
                self?.vc.clearBtn.isHidden = false
                self?.vc.recentViewSetup()
                self?.vc.recentAdapter.recentSearchHistories = data.contents
                self?.vc.collectionView.reloadData()
            case .failure(let error):
                if error.localizedDescription.contains("Empty response"){

                }
            }
        }
    }
    
    
    func  demoChangeAdapter(){
        searchState = SearchState.initail
        if(vc.searchTf.isEditing){
            vc.clearBtn.isHidden = true
            vc.clearSearchBtn.isHidden  = false
            if (vc.searchTf.text?.trimmingCharacters(in: .whitespaces).isEmpty == true){
                searchState = SearchState.searchTfFocused
            }else{
                vc.clearBtn.isHidden = true
                searchState = SearchState.searching
            }
        }else{
            searchState = SearchState.initail
            vc.clearSearchBtn.isHidden  = true
        }
        switch(searchState){
        case .initail:
            vc.genreViewSetup()
        case .searchTfFocused:
            if ShadhinCore.instance.defaults.userIdentity.isEmpty{
                vc.clearBtn.isHidden = true
                vc.genreViewSetup()
            } else {
                checkAndSetupRecentHistories()
            }
        case .searching:
            vc.allSearchSetup()
            vc.allSearchCell?.reset()
            selectedContentType = "All"
            searchTimer?.invalidate()
            // Start a new timer
            searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchAfterDelay), userInfo: nil, repeats: false)
        }
    }
    // Function called after a delay of 0.5 seconds
    @objc func searchAfterDelay() {
        if let searchText = vc.searchTf.text?.trimmingCharacters(in: .whitespaces), !searchText.isEmpty{
            showProgressView()
            self.curretSearchTerm = searchText
            if ShadhinCore.instance.isUserLoggedIn {
                postSearchHistory(searchText: searchText)
            }
            getSearchResultForAll_Updated(searchText: searchText)
        }
    }
    
    private func getSearchResultForAll_Updated(searchText: String) {
        showProgressView()
        ShadhinCore.instance.api.getUpdatedSearchResult_V2(searchText: searchText) {[weak self] responseModel in
            guard let self = self else {return}
            switch responseModel {
            case .success(let data):
                if self.oldSearchTerm?.trimmingCharacters(in: .whitespaces) == self.curretSearchTerm?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    self.sendData(allSearchData: [data.contents], isAllSearch: true)
                    self.hideProgressView()
                }
            case .failure(let error):
                if self.oldSearchTerm?.trimmingCharacters(in: .whitespaces) == self.curretSearchTerm?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    print(error)
                    self.couldNotFindDataChange(content: oldSearchTerm ?? "")
                    self.hideProgressView()
                }
            }
        } sendSearchTerm: {[weak self] searchTerm in
            self?.oldSearchTerm = searchTerm
        }

    }
    
    private func postSearchHistory(searchText:String) {
        ShadhinCore.instance.api.postSearchHistories_V2(userName:ShadhinCore.instance.defaults.userIdentity , searchText: searchText) { responseModel in
            switch responseModel {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func searchWhenContentTypeIsNotAll() {
        guard let searchText = vc.searchTf.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        guard !searchText.isEmpty else {return}
        showProgressView()
        if ShadhinCore.instance.isUserLoggedIn {
            searchWhenUserIsLoggedIn(searchText: searchText)
        } else {
            searchWhenUserIsNotLoggedIn(searchText: searchText)
        }
    }
    
    func sendData(allSearchData: [[SearchV2Content]], isAllSearch: Bool = false) {
        vc.allSearchAdapter.handleDataNotification(["data": allSearchData], isAllSearch: isAllSearch)
    }
    func couldNotFindDataChange(content:String) {
        vc.allSearchAdapter.handleDataNotification(["data": content])
    }
    
    func sendErrorData(shouldShowErrorMsg: Bool) {
        vc.allSearchAdapter.handleDataNotification(["data": shouldShowErrorMsg])
    }
    
    
    private func searchWhenUserIsLoggedIn(searchText: String) {
        performSpecificSearch(searchText: searchText, contentType: selectedContentType)
        /*
        ShadhinCore.instance.api.getSearchResultFromHistory_V2(searchText: searchText, userCode: ShadhinCore.instance.defaults.userIdentity) {[weak self] responseModel in
            guard let self = self else {return}
            switch responseModel {
            case .success(let data):
                if self.oldSearchTerm?.trimmingCharacters(in: .whitespaces) == self.curretSearchTerm?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    if let winningContent = self.findMaxSimilarityType(histories: data.contents), !winningContent.type.isEmpty {
                        if selectedContentType == "All" {
                            self.performSearch(searchText: winningContent.contentName, contentType: winningContent.type)
                        } else {
                            self.performSpecificSearch(searchText: winningContent.contentName, contentType: selectedContentType)
                        }
                    } else {
                        self.searchWhenUserIsNotLoggedIn(searchText: searchText)
                    }
                }
            case .failure(_):
                self.searchWhenUserIsNotLoggedIn(searchText: searchText)
            }
        } sendSearchTerm: {[weak self] oldSearchTerm in
            self?.oldSearchTerm = oldSearchTerm
        }
         */
    }
    
    private func searchWhenUserIsNotLoggedIn(searchText: String) {
        performSpecificSearch(searchText: searchText, contentType: selectedContentType)
        /*
        ShadhinCore.instance.api.getSearchResultFromDatabaseV2(searchText: searchText) {[weak self] responseModel in
            guard let self = self else {return}
            switch responseModel {
            case .success(let data):
                if oldSearchTerm?.trimmingCharacters(in: .whitespacesAndNewlines) == curretSearchTerm?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    if let winningContent = self.findMaxSimilarityType(historiesFromDb: data.contents), !winningContent.type.isEmpty{
                        if selectedContentType == "All"{
                            self.performSearch(searchText: winningContent.contentName, contentType: winningContent.type)
                        } else {
                            self.performSpecificSearch(searchText: winningContent.contentName, contentType: selectedContentType)
                        }
                    } else {
                        self.sendErrorData(shouldShowErrorMsg: true)
                        self.couldNotFindDataChange(content: oldSearchTerm ?? "")
                    }
                }
                
            case .failure(_):
                self.hideProgressView()
                self.sendErrorData(shouldShowErrorMsg: true)
                self.couldNotFindDataChange(content: oldSearchTerm ?? "")
            }
        } sendSearchTerm: {[weak self] oldSearchTerm in
            self?.oldSearchTerm = oldSearchTerm
        }
         */
    }
    
    private func findMaxSimilarityType(historiesFromDb: [ResultDatabaseContent])->ResultDatabaseContent? {
        // Find the maximum value in the array
        let max = historiesFromDb.max(by: { $0.similarity < $1.similarity })
        // Filter the array to get all elements equal to the maximum value
        let maxValues =  historiesFromDb.filter { $0.similarity == max?.similarity }
        return maxValues.first
    }
    
    private func findMaxSimilarityType(histories: [HistoryContent])->HistoryContent? {
        // Find the maximum value in the array
        let max = histories.max(by: { $0.similarity < $1.similarity })
        // Filter the array to get all elements equal to the maximum value
        let maxValues =  histories.filter { $0.similarity == max?.similarity }
        return maxValues.first
    }
    
    func performSearch(searchText: String, contentType: String) {
        var modifiedContentType = contentType
        if contentType.starts(with: "PD") || contentType.starts(with: "VD"){
            modifiedContentType = "PS"
        }
        
        ShadhinCore.instance.api.getSearchResultV2(searchText: searchText, contentType: modifiedContentType) {[weak self] responseModel in
            guard let self = self else {return}
            self.hideProgressView()
            switch responseModel{
            case .success(let data):
                // self.vc.searchTf.resignFirstResponder()
                let filteredTwoDSearchData = self.makeTwoDArray(songs: data.contents)
                if filteredTwoDSearchData.isEmpty {
                    self.sendErrorData(shouldShowErrorMsg: true)
                    self.couldNotFindDataChange(content: oldSearchTerm ?? "")
                    return
                }
                self.sendData(allSearchData: filteredTwoDSearchData)
            case .failure(let error):
                self.sendErrorData(shouldShowErrorMsg: true)
                self.couldNotFindDataChange(content: oldSearchTerm ?? "")
                print(error)
            }
        }
        
    }
    
    func performSpecificSearch(searchText: String, contentType: String) {
        var modifiedContentType = contentType
        if contentType.starts(with: "PD") || contentType.starts(with: "VD"){
            modifiedContentType = "PS"
        }
        print(searchText, modifiedContentType)
        ShadhinCore.instance.api.getSpecificSearchResultV2(searchText: searchText, contentType: modifiedContentType) {[weak self] responseModel in
            guard let self = self else {return}
            self.hideProgressView()
            switch responseModel{
            case .success(let data):
                let filteredTwoDSearchData = self.makeTwoDArray(songs: data.contents)
                if filteredTwoDSearchData.isEmpty {
                    self.sendErrorData(shouldShowErrorMsg: true)
                    self.couldNotFindDataChange(content: oldSearchTerm ?? "")
                    return
                }
                
                if filteredTwoDSearchData.first?.count == 0{
                    self.sendData(allSearchData: filteredTwoDSearchData)
                    self.sendErrorData(shouldShowErrorMsg: true)
                    self.couldNotFindDataChange(content: oldSearchTerm ?? "")
                    return

                }
                
                self.sendData(allSearchData: filteredTwoDSearchData)
                
                
            case .failure(let error):
                self.sendErrorData(shouldShowErrorMsg: true)
                self.couldNotFindDataChange(content: oldSearchTerm ?? "")
                print(error)
            }
        }
        
    }
    
    func makeTwoDArray(songs:[SearchV2Content]) -> [[SearchV2Content]] {
        
        if selectedContentType == "A" {
            var artists = [SearchV2Content]()
            songs.forEach { content in
                var artist = content
                artist.resultType = SearchAllResultType.artists.rawValue
                artists.append(artist)
            }
            return [artists]
        }
        
        if selectedContentType == "R" {
            var albums = [SearchV2Content]()
            songs.forEach { content in
                var album = content
                album.resultType = SearchAllResultType.album.rawValue
                albums.append(album)
            }
            return [albums]
        }
        
        if selectedContentType == "S" {
            var tracks = [SearchV2Content]()
            songs.forEach { content in
                var track = content
                track.resultType = SearchAllResultType.tracks.rawValue
                tracks.append(track)
            }
            return [tracks]
        }
        
        if selectedContentType == "V" {
            var videos = [SearchV2Content]()
            songs.forEach { content in
                var video = content
                video.resultType = SearchAllResultType.videos.rawValue
                videos.append(video)
            }
            return [videos]
        }
        
        if selectedContentType == "P" {
            var playlists = [SearchV2Content]()
            songs.forEach { content in
                var playlist = content
                playlist.resultType = SearchAllResultType.playlists.rawValue
                playlists.append(playlist)
            }
            return [playlists]
        }
        
        var filteredSongs: [[SearchV2Content]] = []
        songs.forEach { song in
            var songFound = false
            for (index, songsArray) in filteredSongs.enumerated() {
                if songsArray.first?.resultType == song.resultType {
                    filteredSongs[index].append(song)
                    songFound = true
                    break
                }
            }
            
            if !songFound {
                filteredSongs.append([song])
            }
        }
        return filteredSongs
    }
    
    
    enum SearchState{
        case initail
        case searchTfFocused
        case searching
    }
    
}

extension GenreAdapter : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchState == .searching ? filteredPlayLists.count : playLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCollectionViewCell.identifier, for: indexPath) as? GenreCollectionViewCell else{
            fatalError()
        }
        cell.bindData(data: searchState == .searching ? filteredPlayLists[indexPath.item]:playLists[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        vc.coordinator?.routeToContent(content: playLists[indexPath.item].toCommonContent())
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (SCREEN_WIDTH - (16*2)-8)/2
        return CGSize(width: width,height:width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
