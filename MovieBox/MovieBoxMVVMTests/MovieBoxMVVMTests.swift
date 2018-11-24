//
//  MovieBoxMVVMTests.swift
//  MovieBoxMVVMTests
//
//  Created by Göksel Köksal on 24.11.2018.
//  Copyright © 2018 Late Night Muhabbetleri. All rights reserved.
//

import XCTest
@testable import MovieBoxAPI
@testable import MovieBoxMVVM

class MovieBoxMVVMTests: XCTestCase {
    
    private var viewModel: MovieListViewModel!
    private var view: MockMovieListView!
    private var service: MockTopMoviesService!
    
    private let movie1 = try! ResourceLoader.loadMovie(resource: .movie1)
    private let movie2 = try! ResourceLoader.loadMovie(resource: .movie2)

    override func setUp() {
        service = MockTopMoviesService()
        view = MockMovieListView()
        viewModel = MovieListViewModel(service: service)
        viewModel.delegate = view
    }

    func testFetchMovies() throws {
        // Given:
        service.movies = [movie1, movie2]
        
        // When:
        viewModel.load()
        
        // Then:
        XCTAssertEqual(view.outputs.count, 4)
        
        switch try view.outputs.element(at: 0) {
        case .updateTitle:
            break // Don't fail.
        default:
            XCTFail()
        }
        
        switch try view.outputs.element(at: 1) {
        case .setLoading(let loading):
            XCTAssertTrue(loading)
        default:
            XCTFail()
        }
        
        switch try view.outputs.element(at: 2) {
        case .setLoading(let loading):
            XCTAssertFalse(loading)
        default:
            XCTFail()
        }
        
        switch try view.outputs.element(at: 3) {
        case .showMovies(let presentations):
            XCTAssertEqual(presentations.count, 2)
            XCTAssertEqual(try presentations.element(at: 0), MoviePresentation(movie: movie1))
            XCTAssertEqual(try presentations.element(at: 1), MoviePresentation(movie: movie2))
        default:
            XCTFail()
        }
    }
    
    func testSelectMovie() throws {
        // Given:
        service.movies = [movie1, movie2]
        viewModel.load()
        view.outputs.removeAll() // Clean outputs.
        
        // When:
        viewModel.selectMovie(at: 0)
        
        // Then:
        XCTAssertEqual(view.outputs.count, 1)
        
        switch try view.outputs.element(at: 0) {
        case .showMovieDetail(_):
            break // Don't fail.
        default:
            XCTFail()
        }
    }
}

private class MockMovieListView: MovieListViewModelDelegate {
    
    var outputs: [MovieListViewModelOutput] = []
    
    func handleViewModelOutput(_ output: MovieListViewModelOutput) {
        outputs.append(output)
    }
}
