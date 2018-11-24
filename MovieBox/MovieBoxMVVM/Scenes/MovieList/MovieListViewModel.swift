//
//  MovieListViewModel.swift
//  MovieBoxMVVM
//
//  Created by Göksel Köksal on 24.11.2018.
//  Copyright © 2018 Late Night Muhabbetleri. All rights reserved.
//

import Foundation
import MovieBoxAPI

final class MovieListViewModel: MovieListViewModelProtocol {
    
    weak var delegate: MovieListViewModelDelegate?
    
    private let service: TopMoviesServiceProtocol
    private var movies: [Movie] = []
    
    init(service: TopMoviesServiceProtocol) {
        self.service = service
    }
    
    func load() {
        notify(.updateTitle("Movies"))
        fetchMovies()
    }
    
    func selectMovie(at index: Int) {
        let movie = movies[index]
        let viewModel = MovieDetailViewModel(movie: movie)
        notify(.showMovieDetail(viewModel))
    }
    
    private func fetchMovies() {
        notify(.setLoading(true))
        service.fetchTopMovies { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            strongSelf.notify(.setLoading(false))
            switch result {
            case .success(let response):
                strongSelf.movies = response.results
                let presentations = response.results.map(MoviePresentation.init)
                strongSelf.notify(.showMovies(presentations))
            case .failure(let error):
                strongSelf.notify(.handleError(error))
            }
        }
    }
    
    private func notify(_ output: MovieListViewModelOutput) {
        delegate?.handleViewModelOutput(output)
    }
}
