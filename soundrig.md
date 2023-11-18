# SoundRig CIP 68

In order to get this over the line I need to:

Organise the metadata so I can print to data

Build the transaction in Lucid

Create 2 test wallets

Set the parameters for the validators

Rewrite the validators in cip68 to work with these parameters

---

Metadata Validator:

Needs to know the owner PKH

Minting Policy:

Needs to know the validator to send to

The lucid code can set the metadata appropriately and can check that it matches the initial metadata?

We could also set the initial metadata in Lucid and not worry too much about the minting policy I guess, I think i will do this for now.

---

I have some version of the lucid code in CIP68 folder so I can refer to it there.

---

Test Metadata:

{
  "721": {
    "<policy_id>": {
      "<asset_name>": {
        "distributor": "https://www.soundrig.io/",
        "files": [
          {
            "encrypted": "true",
            "mediaType": "image/png",
            "name": "Album Cover",
            "src": "ipfs://QmTe5ReZ87nvWRsX4VMdEdgaKntPQMBh8ybJNpHyxHWhjz"
          },
          {
            "album_title": "Rose Riot",
            "artists": [
              "Samantha Sharman"
            ],
            "contributing_artists": [
              "Mike Pierre"
            ],
            "copyright": "℗ Sam Sharman",
            "encrypted": "true",
            "explicit": "TRUE",
            "genres": [
              "R&B",
              "Rap",
              "Pop"
            ],
            "isrc": "QZES72383824",
            "master_engineer": "Jon Margulies",
            "mediaType": "audio/wav",
            "mix_engineer": "Jon Margulies",
            "mood": "Sexy, Real Talk, Empowered",
            "name": "Words Spoken",
            "producer": "OVSMA",
            "recording_engineer": "Jeremy Classic",
            "song_duration": "PT3M33S",
            "song_title": "Words Spoken",
            "special_thanks": [
              "Ahmed",
              "Goddessey",
              "Friz"
            ],
            "src": "ipfs://Qmaq2rXucenzgAd7Ws7au5xEqTpLk3uTYNV9m5HC6tohJF",
            "track_number": "1",
            "visual_artist": [
              "Sam Sharman",
              "Skylar Smith"
            ]
          },
          {
            "encrypted": "true",
            "mediaType": "text/plain",
            "name": "Words Spoken Lyrics",
            "src": "ipfs://QmQijaDcxc8BpNvK28Ab7zUeZs4LQXZfq7gT7ZbyzQPQKe"
          },
          {
            "encrypted": "true",
            "mediaType": "video/mp4",
            "name": "Words Spoken",
            "src": "ipfs://QmQb6aiP7xtHKTLDzMhew6f1MMWQUD82hMMv7nfEtCjwti"
          },
          {
            "encrypted": "true",
            "mediaType": "video/mp4",
            "name": "Behind the Scenes",
            "src": "ipfs://QmQPr8T8GnKGgkpMDv16TepDqrdWaFAZ6yqS9pSvHy9Dkm"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "Spring Shoot_ Attitude",
            "src": "ipfs://QmXR4YfNAmfMELEenK4jC2SuRywLkYeepPamkfwXkon8m4"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "Spring Shoot_ Hollywood Blvd",
            "src": "ipfs://QmPnTHj3odzzMaMWUaJNnXtwguM4WU1eJArhwRBnkpUS8m"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "Spring Shoot_ Inside a Laugh",
            "src": "ipfs://QmeYrNwFpXh9VtKFZBb15YbWH57XKboZTdZh84C9skUbRk"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "Spring Shoot_ Let it Out",
            "src": "ipfs://QmZf3CCR3QYFWcu545118mePwggATyeFunJWE914cmRiLA"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "Spring Shoot_ Mauve Strawberry",
            "src": "ipfs://QmSKAPcLjcXNj6quLReFXuordqLeKwJk4aHoXq5edbxPEo"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "Spring Shoot_ Movement",
            "src": "ipfs://QmZAwp6gt1PB5r8cAW7zQugz8QPvUE3W3nYU56WXNeR4Lr"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "Spring Shoot_ Pink Velvet",
            "src": "ipfs://QmUH7Bc8n6sifv1gDeHNpXt9fHGY6F7ZwYVDypVSBe58Ne"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "Spring Shoot_ Pink",
            "src": "ipfs://QmRAAg4tLFfQjNM4FbXUVhCGm7rFeQu95fVPxSmDzLFpgN"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "Spring Shoot_ Transcendental",
            "src": "ipfs://QmT7TAvHoeMsLJWJo4gk3sfhcQPHYm2THJyry6QRWuduVZ"
          },
          {
            "album_title": "Rose Riot",
            "artists": [
              "Samantha Sharman"
            ],
            "contributing_artists": [
              "Mike Pierre",
              "INOY"
            ],
            "copyright": "℗ Sam Sharman",
            "encrypted": "true",
            "explicit": "FALSE",
            "featured_artist": [
              "INOY"
            ],
            "genres": [
              "Pop",
              "R&B",
              "Rap"
            ],
            "isrc": "QZXLZ2330000",
            "master_engineer": "Thodoris Stamatogiannakis",
            "mediaType": "audio/wav",
            "mix_engineer": "Thodoris Stamatogiannakis",
            "mood": "Sad, Heartbreak, Love Song",
            "name": "Words Spoken Acoustic",
            "recording_engineer": "Johnny Fero",
            "song_duration": "PT3M11S",
            "song_title": "Words Spoken Acoustic",
            "special_thanks": [
              "Ahmed",
              "Goddessey",
              "Friz"
            ],
            "src": "ipfs://QmPaAcgv2j1hBiykHZEr7oqk2eLVLQhGPGb9qj16XgyizC",
            "track_number": "2"
          },
          {
            "encrypted": "true",
            "mediaType": "video/mp4",
            "name": "Words Spoken Acoustic",
            "src": "ipfs://QmeG2qB1J9Lk5tKCxdL6n73xPFYhuYQuaFNS3vZA2wZDus"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "In the Studio_ Close Up",
            "src": "ipfs://QmRRriWShaxAAwbQcw8g8ZGGhPErf63hdweLxfP2LFntN2"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "In the Studio_ Sam _ Nick, 2",
            "src": "ipfs://QmPWU9nwiTCXzBuVd6WSFPoqTqJK6ordtwia2q19ad9EeV"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "In the Studio_ Sam _ Nick, 3",
            "src": "ipfs://QmZFL1zdm5cCDn9fCGH3AsvVQvKjq6BFFtVJE8aCJsW3Rn"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "In the Studio_ Sam _ Nick",
            "src": "ipfs://Qmc6PvnxUxdLPw9fY7UWY7gSMRB3DuRQQPwHSs69egz4KD"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "In the Studio_ Sam and Nick 3",
            "src": "ipfs://QmPuW7uQiwTXgapvu68VoG7ar3xQZJJQ6gvGLVPCaFnmuV"
          },
          {
            "encrypted": "true",
            "mediaType": "image/jpg",
            "name": "In the Studio_ The Friz",
            "src": "ipfs://QmR5pEmVvS1qzg76Bs2wkgQUw2g71MiS1qD9NAagkq7wMA"
          },
          {
            "album_title": "Rose Riot",
            "artists": [
              "Samantha Sharman"
            ],
            "contributing_artists": [
              "Segnon"
            ],
            "copyright": "℗ Sam Sharman",
            "encrypted": "true",
            "explicit": "FALSE",
            "genres": [
              "Rap",
              "Pop",
              "R&B"
            ],
            "isrc": "QZXLZ2329999",
            "master_engineer": "The Friz",
            "mediaType": "audio/wav",
            "mix_engineer": "The Friz",
            "mood": "Fierce, Empowered, Magical",
            "name": "I AM S A M",
            "producer": "Segnon",
            "recording_engineer": "Segnon",
            "song_duration": "PT5M26S",
            "song_title": "I AM S A M",
            "special_thanks": [
              "Ahmed",
              "Goddessey",
              "Friz",
              "Segnon"
            ],
            "src": "ipfs://QmUREnrgBQDjXGPkZwLf9JLpy42SFPEy5sUTApw7798E49",
            "track_number": "3",
            "visual_artist": [
              "Sam Sharman",
              "Skylar Smith"
            ]
          },
          {
            "encrypted": "true",
            "mediaType": "text/plain",
            "name": "I AM SAM Lyrics",
            "src": "ipfs://QmZsZjQaoGCUwvxwd3nJ5T8U7KwEUvi67qrGBFRccmiL7k"
          },
          {
            "encrypted": "true",
            "mediaType": "video/mp4",
            "name": "I AM SAM",
            "src": "ipfs://QmWbwhweJUpQvaqpEtffQtDrK2ppABYBp4nU8mbnBm1Qdv"
          },
          {
            "encrypted": "true",
            "mediaType": "image/png",
            "name": "I AM SAM_ Clandestine",
            "src": "ipfs://QmSDJPBFtf6fxv8PJSEuMUBTgki6WVEjmWakd5XWJACM8G"
          },
          {
            "encrypted": "true",
            "mediaType": "image/png",
            "name": "I AM SAM_ Flame",
            "src": "ipfs://QmSTNxFGvpRais26rmkc1Ra2pt2aidmYCykAeQ6v91ddva"
          },
          {
            "encrypted": "true",
            "mediaType": "image/png",
            "name": "I AM SAM_ Orange",
            "src": "ipfs://QmR9ymbBXwL9maeV3bdtQ7SsePQnpMFgh5YXafAC9P4BkL"
          },
          {
            "encrypted": "true",
            "mediaType": "image/png",
            "name": "I AM SAM_ Reflexion",
            "src": "ipfs://QmTQDB4Rwymz1VK6iGWxHhr28Gnf8FEz1YvBDYEMc6kmea"
          },
          {
            "encrypted": "true",
            "mediaType": "image/png",
            "name": "I AM SAM_ Trinity",
            "src": "ipfs://QmXR2zGY9QxK8L3ghhWn81YLyk9etEUsubcqHBPJnYd68v"
          },
          {
            "encrypted": "true",
            "mediaType": "image/png",
            "name": "I AM SAM_ Vision",
            "src": "ipfs://QmXt6KAgbsWMHr6VDFKpHC8imTQE2LXTHCoyR1kV6B6vV7"
          }
        ],
        "image": "ipfs://QmZBdUTpsZjLFfQvJ7bgcZNpEJqTTHUCtjEnqJSp22gXfi",
        "mediaType": "image/png",
        "music_metadata_version": "v1",
        "name": "<display_name>",
        "release_date": "2023-13-08",
        "release_type": "multiple"
      }
    }
  }
}
