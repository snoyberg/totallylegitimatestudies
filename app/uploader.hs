{-# LANGUAGE NoImplicitParams #-}
{-# LANGUAGE OverloadedStrings #-}
import RIO
import Text.HTML.DOM
import Text.XML.Cursor
import Network.HTTP.Client (parseUrlThrow)
import Network.HTTP.Simple
import qualified RIO.Map as Map
import qualified RIO.Set as Set
import qualified RIO.Text as T
import qualified RIO.ByteString as B

import Network.AWS
import Network.AWS.Data.Body
import Network.AWS.S3
import Network.AWS.S3.PutObject

data Route = Route
  { routeMime :: !Text
  , routeBody :: !ByteString
  }

data S = S
  { routes :: !(Map Text Route)
  , toProcess :: !(Set Text)
  }

main :: IO ()
main = runSimpleApp $ do
  awsEnv <- liftIO $ newEnv Discover
  final <- start "localhost:3000" S
    { routes = mempty
    , toProcess = Set.singleton ""
    }
  forM_ (Map.toList final) $ \(key', route) -> do
    let key = if key' == "" then "index.html" else key'
        po =
          set poContentType (Just $ routeMime route) $
          set poACL (Just OPublicRead) $
          putObject
            "www.totallylegitimatestudies.com"
            (ObjectKey key)
            (Hashed $ toHashed $ routeBody route)
    logInfo $ "Uploading " <> display key
    res <- runResourceT $ runAWS awsEnv $ send po
    logInfo $ displayShow res

start domain =
    loop
  where
    loop s0 =
      case Set.minView $ toProcess s0 of
        Nothing -> pure $ routes s0
        Just (next, rest)
          | next `Map.member` routes s0 -> loop s0 { toProcess = rest }
          | otherwise -> do
              route <- getRoute domain next
              let links = parseLinks route
              loop S
                { routes = Map.insert next route $ routes s0
                , toProcess = Set.union links $ toProcess s0
                }

parseLinks :: Route -> Set Text
parseLinks route
  | "text/html" `T.isPrefixOf` routeMime route =
      let doc = parseBSChunks [routeBody route]
          cursor = fromDocument doc
          urls = mapMaybe ("/" `T.stripPrefix`) $ concatMap
            (\c -> laxAttribute "src" c ++ laxAttribute "href" c)
            (cursor $// anyElement)
       in Set.fromList urls
  | otherwise = mempty

getRoute
  :: Text -- ^ domain
  -> Text -- ^ path
  -> RIO SimpleApp Route
getRoute domain path = do
  let url = mconcat ["http://", domain, "/", path]
  req <- parseUrlThrow $ T.unpack url
  res <- httpBS req
  case lookup "content-type" $ getResponseHeaders res of
    Nothing -> error $ "No content-type: " ++ show (void res)
    Just mime ->
      case decodeUtf8' mime of
        Left e -> throwIO e
        Right mime' -> pure Route
          { routeMime = mime'
          , routeBody = getResponseBody res
          }
