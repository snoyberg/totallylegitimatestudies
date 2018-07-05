{-# LANGUAGE NoImplicitPrelude #-}
module Import
    ( module Import
    ) where

import Foundation            as Import
import Import.NoFoundation   as Import
import qualified RIO.Map     as Map

getStudy :: Text -> Handler Study
getStudy key = do
  studies <- appStudies <$> getYesod
  maybe notFound pure $ Map.lookup key studies
