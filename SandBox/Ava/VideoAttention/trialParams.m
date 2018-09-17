function [IDArray,movieArray] = trialParams(numTrials, numMovies)
    %Creates arrays needed for movie trials with left and right screens.
    %  PARAMS
    %  int numTrials : The number of trials, > 0
    %  int numMovies : The number of movies, between 1 - 9
    % 
    %  RETURNS
    %  int [] IDArray : Random permutation of possible states: 11, 21, 12, 22
    %                   The first integer corresponds to frequency: 1 is the
    %                   lower of the two frequencies and 2 is the higher.
    %                   The second integer corresponds to screen side: 1 is
    %                   the left side and 2 is the right.
    %  int [] movieArray : Random permutation of possible states based on 
    %                      number of movies. First digit is always 5 to 
    %                      correspond to the marker. Second digit is between
    %                      0 to 9 and corresponds to specific movie.

    possibleCases = [11, 21, 12, 22];
    possibleCases =  possibleCases(randperm(length(possibleCases));
    IDArray = [];
    movieArray = [];

    for x=1:numMovies
        movieArray = [movieArray (49+x)];
    end
    movieArray =  movieArray(randperm(length(movieArray));

    for x=1:numTrials
        IDArray = [IDArray possibleCases(mod(x,4))];
        movieArray = [movieArray possibleCases(mod(x,numMovies))];
    end    
    IDArray = IDArray(randperm(length(IDArray));
    movieArray = movieArray(randperm(length(movieArray));


end

