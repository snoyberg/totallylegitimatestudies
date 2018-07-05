{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Studies where

import ClassyPrelude.Yesod
import CMarkGFM
import System.FilePath (takeBaseName)
import Text.HTML.DOM (parseSTChunks)
import Text.XML.Cursor

data Study = Study
  { studyTitle :: !Text
  , studyBody :: !Html
  -- ^ includes the title as well
  }

type Studies = Map Text Study

loadStudies
  :: MonadIO m
  => FilePath -- ^ directory
  -> m Studies
loadStudies dir =
      liftIO
    $ runConduitRes
    $ sourceDirectory dir
   .| filterC (".md" `isSuffixOf`)
   .| foldMapMC go

go :: MonadIO m => FilePath -> m Studies
go fp = do
  text <- readFileUtf8 fp
  let body = commonmarkToHtml
        [optSmart]
        [extStrikethrough, extTable, extAutolink]
        text
      doc = parseSTChunks [body]
      cursor = fromDocument doc
      err str = error $ "Could not process: " ++ fp ++ ": " ++ str
  title <-
    case cursor $// element "h1" of
      [] -> err "No h1 heading found"
      _:_:_ -> err "Multiple h1 headings found"
      [h1] -> pure $ mconcat $ h1 $// content
  return $ singletonMap (pack $ takeBaseName fp) Study
    { studyTitle = title
    , studyBody = preEscapedToMarkup body
    }
