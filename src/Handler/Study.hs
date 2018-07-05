{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Study where

import Import

getStudyR :: Text -> Handler Html
getStudyR key = do
  study <- getStudy key
  defaultLayout $ do
    setTitle $ toHtml $ studyTitle study
    $(widgetFile "study")
