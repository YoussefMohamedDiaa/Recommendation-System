data Item = I String deriving (Show, Eq)
data User = U String deriving (Show, Eq)

data Fractional r => Rating r = R  r | NoRating deriving (Show, Eq)


member :: Eq a => a -> [a] -> Bool
member e [] = False
member e (x:xs) = 
    if(e == x)
        then True
    else
        member e xs

len :: Num b => [a] -> b
len [] = 0
len (_:xs) = 1 + len xs

--getRatingAt
getRatingAt :: Num a => a -> [b] -> b
getRatingAt 0 (x:xs) = x
getRatingAt idx (x:xs) = getRatingAt (idx - 1) xs

-- getUserAt
getUserAt :: Num a => a -> [b] -> b
getUserAt 0 (x:xs) = x
getUserAt idx (x:xs) = getUserAt (idx - 1) xs

-- getR
getR :: Fractional a => Rating a -> a
getR (R x) = x

dis :: Eq a => [a] -> [a]
dis [] = []
dis (x:xs) = 
    if(member x xs)
        then dis xs
    else
        x : dis xs

fromRatingsToItems :: Eq a => [(b, a, c)] -> [a]
fromRatingsToItems [] = []
fromRatingsToItems ((_, x, _):xs) = 
    dis (x : fromRatingsToItems xs)

fromRatingsToUsers :: Eq a => [(a, b, c)] -> [a]
fromRatingsToUsers [] = []
fromRatingsToUsers ((x, _, _):xs) =
    dis (x : fromRatingsToUsers xs)

hasRating :: (Eq a, Eq b) => a -> b -> [(a, b, c)] -> Bool
hasRating _ _ [] = False
hasRating u i ((user, item, _):xs) =
    if(u == user && i == item)
        then True
    else
        hasRating u i xs

getRating :: (Eq a, Eq b) => a -> b -> [(a, b, c)] -> c
getRating u i l = 
    if(hasRating u i l)
        then getRatingHelper u i l
    else
        error "No given rating"

getRatingHelper :: (Eq a, Eq b) => a -> b -> [(a, b, c)] -> c
getRatingHelper u i ((user, item, c):xs) = 
    if(u == user && i == item)
        then c
    else
        getRatingHelper u i xs


formMatrixUser :: (Eq a, Eq b, Fractional c) => a -> [b] -> [(a,b,c)] -> [Rating c]
formMatrixUser _ [] _ = []
formMatrixUser user (item:items) list = 
    if(hasRating user item list)
        then R (getRating user item list) : formMatrixUser user items list
    else 
        NoRating : formMatrixUser user items list


formMatrix :: (Fractional a, Eq b, Eq c) => [c] -> [b] -> [(c,b,a)] -> [[Rating a]]
formMatrix [] _ _ = []
formMatrix (user:users) items list =
    (formMatrixUser user items list) : formMatrix users items list


numberRatingsGivenItem :: (Num a, Fractional b, Num c) => c -> [[Rating b]] -> a
numberRatingsGivenItem _ [] = 0
numberRatingsGivenItem idx (x:xs) = (hasRatingAt idx x) + numberRatingsGivenItem idx xs


hasRatingAt :: (Num a, Fractional b, Num c) => a -> [Rating b] -> c
hasRatingAt _ [] = 0
hasRatingAt 0 (x:xs) = 
    if(x /= NoRating)
        then 1
    else 
        0
hasRatingAt idx (x:xs) = hasRatingAt (idx - 1) xs


differeneRatings :: Fractional a => Rating a -> Rating a -> a
differeneRatings NoRating _ = 0
differeneRatings _ NoRating = 0
differeneRatings (R x) (R y) = x - y


matrixPairs :: Num a => a -> [(a,a)]
matrixPairs 0 = []
matrixPairs x = matrixPairsHelper (x-1) (x-1)


matrixPairsHelper :: (Num a, Num b) => b -> a -> [(b,a)]
matrixPairsHelper (-1) _ = []
matrixPairsHelper x y = 
    (matrixPairsHelper (x-1) y)  ++ makeRow x y


makeRow :: Num a => b -> a -> [(b,a)]
makeRow x 0 = [(x,0)]
makeRow x y = (makeRow x (y-1)) ++ [(x,y)]


dMatrix :: Fractional a => [[Rating a]] -> [a]
dMatrix [] = []
dMatrix (x:xs) = dMatrixHelper (matrixPairs (len x)) (x:xs)

--dMatrixHelper
dMatrixHelper :: (Fractional a, Num b, Num c) => [(c,b)] -> [[Rating a]] -> [a]
dMatrixHelper [] _ = []
dMatrixHelper (x:xs) l = (pairDiff x l) : dMatrixHelper xs l

--pairDiff
pairDiff :: (Num a, Num b, Fractional c) => (a,b) -> [[Rating c]] -> c
pairDiff _ [] = 0
pairDiff (x,y) (l:ls) = differeneRatings (getRatingAt x l) (getRatingAt y l) + pairDiff (x,y) ls


freqMatrix :: (Fractional a, Num b) => [[Rating a]] -> [b]
freqMatrix [] = []
freqMatrix (x:xs) = freqMatrixHelper (matrixPairs (len x)) (x:xs)

--freqMatrixHelper
freqMatrixHelper :: (Num a, Fractional b, Num c, Num d) => [(c,a)] -> [[Rating b]] -> [d]
freqMatrixHelper [] _ = []
freqMatrixHelper (x:xs) l = (pairFreq x l) : freqMatrixHelper xs l

-- pairFreq 
pairFreq :: (Num a, Num b, Fractional c, Num d) => (b,d) -> [[Rating c]] -> a
pairFreq _ [] = 0
pairFreq (i, j) (l:ls) = (hasRatingAt i l) * (hasRatingAt j l) + pairFreq (i, j) ls


diffFreqMatrix :: Fractional a => [[Rating a]] -> [a]
diffFreqMatrix [] = []
diffFreqMatrix l = diffFreqMatrixHelper (dMatrix l) (freqMatrix l)

-- diffFreqMatrixHelper
diffFreqMatrixHelper :: Fractional a => [a] -> [a] -> [a]
diffFreqMatrixHelper [] _ = []
diffFreqMatrixHelper _ [] = []
diffFreqMatrixHelper (x:xs) (y:ys) = (x / y) : diffFreqMatrixHelper xs ys

-- predict
predict :: (Fractional a, Eq b, Eq c, Num d, Num e) => [(b,c,a)] -> d -> e -> a
predict list userIdx itemIdx =
    if (getRatingAt itemIdx (getUserRatingsList list userIdx itemIdx)) /= NoRating
        then getR (getRatingAt itemIdx (getUserRatingsList list userIdx itemIdx))
    else
        predictCaseB list itemIdx (getUserRatingsList list userIdx itemIdx)

--predictCaseB
predictCaseB :: (Fractional a, Num b, Eq c, Eq d) => [(d,c,a)] -> b -> [Rating a] -> a
predictCaseB list itemIdx userRatings = 
    ((getFilteredRatings list itemIdx userRatings)
                  +
    (sumUserRatings userRatings))/ ((len userRatings) - 1)

--filterRatings
filterRatings :: (Eq a, Num b) => [b] -> [(a,a)] -> a -> b
filterRatings [] _ _ = 0
filterRatings (x:xs) ((a,b):pairs) e =
    if(a == e && b /= e)
        then x + filterRatings xs pairs e
    else
        filterRatings xs pairs e

-- sumUserRatings
sumUserRatings :: Fractional a => [Rating a] -> a
sumUserRatings [] = 0
sumUserRatings (x:xs) =
    if(x == NoRating)
        then sumUserRatings xs
    else
        (getR x) + sumUserRatings xs 

-- getUserRatingsList
getUserRatingsList :: (Eq a, Eq b, Fractional c, Num d) => [(a,b,c)] -> d -> e -> [Rating c]
getUserRatingsList list userIdx itemIdx =
    formMatrixUser (getUserAt userIdx (fromRatingsToUsers list)) (fromRatingsToItems list) list
    
-- getFilteredRatings
getFilteredRatings :: (Num a, Fractional b, Eq c, Eq d) => [(d,c,b)] -> a -> [e] -> b
getFilteredRatings list itemIdx userRatings =
    filterRatings (diffFreqMatrix (formMatrix (fromRatingsToUsers list) (fromRatingsToItems list) list) )
    (matrixPairs (len userRatings))
    itemIdx