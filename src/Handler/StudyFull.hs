{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.StudyFull where

import Import

getStudyFullR :: Text -> Handler Html
getStudyFullR key = do
  study <- getStudy key
  defaultLayout $ do
    let title = toHtml (studyTitle study) <> " - full text"
    setTitle title
    $(widgetFile "study-full")
