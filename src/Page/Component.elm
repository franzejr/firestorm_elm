module Page.Component
    exposing
        ( badgeBlock
        , categoryLink
        , categoryPills
        , itemMetadata
        , postItemActions
        , postView
        , renderOEmbeds
        , threadLink
        , timeAbbr
        , userLink
        )

import Data.Category as Category exposing (Category)
import Data.Post as Post exposing (Post)
import Data.Thread as Thread exposing (Thread)
import Data.User as User exposing (User)
import Date exposing (Date)
import Date.Distance as Distance
import Date.Distance.I18n.En
import Date.Distance.Types
import Html exposing (..)
import Html.Attributes
    exposing
        ( attribute
        , class
        , classList
        , href
        , id
        , src
        , title
        )
import Html.Attributes.Extra exposing (innerHtml)
import Route


locale : Date.Distance.Types.Locale
locale =
    Date.Distance.I18n.En.locale { addSuffix = True }


dateDiffInWords : Date.Date -> Date.Date -> String
dateDiffInWords =
    let
        defaultConfig =
            Distance.defaultConfig
    in
    Distance.inWordsWithConfig
        { defaultConfig | locale = locale }


timeAbbr : Date.Date -> Date.Date -> Html msg
timeAbbr currentDate date =
    abbr
        [ class "time"
        , title <| toString date
        ]
        [ text <| dateDiffInWords currentDate date ]


categoryLink : Category.Category -> Html msg
categoryLink category =
    a
        [ Route.href <| Route.Category category.slug ]
        [ text category.title ]


threadLink : Category.Category -> Thread.Thread -> Html msg
threadLink category thread =
    a
        [ Route.href <| Route.Thread category.slug thread.slug
        , class "title"
        ]
        [ text thread.title ]


userLink : Maybe User -> Html msg
userLink maybeUser =
    case maybeUser of
        Just user ->
            a
                [ Route.href <| Route.User user.username
                , class "user-name"
                ]
                [ text <| User.usernameToString user.username ]

        Nothing ->
            div [] []


itemMetadata : List (Html msg) -> Html msg
itemMetadata =
    div
        [ class "item-metadata" ]


badgeBlock : Bool -> Int -> Html msg
badgeBlock highlighted count =
    div
        [ classList [ ( "badge-block", True ), ( "-highlight", highlighted ) ] ]
        [ text <| toString count ]


categoryPills : List Category.Category -> Html msg
categoryPills categories =
    let
        categoryItem : Category.Category -> Html msg
        categoryItem category =
            li
                [ class "category -color-20" ]
                [ categoryLink category ]
    in
    ul
        [ class "category-pill" ]
        (List.map categoryItem categories)


renderOEmbeds : List ( String, String ) -> List (Html msg)
renderOEmbeds oEmbeds =
    List.map renderOEmbed oEmbeds


renderOEmbed : ( String, String ) -> Html msg
renderOEmbed ( url, html ) =
    div
        [ class "oembed-for"
        , attribute "data-oembed-url" url
        , innerHtml html
        ]
        []


postItemActions : Post -> Html msg
postItemActions post =
    div
        [ class "post-item-actions" ]
        [ div [ class "spacer" ] []
        , ul [ class "actions" ]
            [ li
                [ class "link" ]
                [ a
                    [ href "#" ]
                    [ i [ class "fa fa-link" ] [] ]
                ]
            , li [ class "reply" ]
                [ a [ href "#" ]
                    [ i [ class "fa fa-reply" ] [] ]
                ]
            ]
        ]


postView : Date -> ( Maybe User, Post ) -> Html msg
postView currentDate ( maybeUser, post ) =
    let
        ( avatarUrl, userLink_ ) =
            case maybeUser of
                Nothing ->
                    ( "https://api.adorable.io/avatars/256/nobody@adorable.png"
                    , userLink Nothing
                    )

                Just user ->
                    ( user.avatarUrl
                    , userLink (Just user)
                    )
    in
    li
        [ class "post-item"
        , id ("post-" ++ Post.idToString post.id)
        ]
        ([ div
            [ class "item-metadata" ]
            [ div
                [ class "avatar" ]
                [ img
                    [ src avatarUrl
                    , class "user-avatar -borderless"
                    ]
                    []
                ]
            , userLink_
            , timeAbbr currentDate post.updatedAt
            ]
         , div
            [ class "body"
            , innerHtml post.bodyHtml
            ]
            []
         ]
            ++ renderOEmbeds post.oEmbeds
            ++ [ postItemActions post ]
        )
