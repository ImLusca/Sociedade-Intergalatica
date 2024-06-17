import React, { useEffect, useState } from 'react';
import Styles from "./overview.module.css";
import { useNavigate } from "react-router-dom";
import ChangeNameFacction from "../../components/OverviewCommands/changeFacctionName"
import ChangeLeder from "../../components/OverviewCommands/changeLeader"
import AddCommunity from "../../components/OverviewCommands/addComunity"
import RemoveNation from "../../components/OverviewCommands/removeNation"
import CreateNewFed from '../../components/OverviewCommands/createNewFed';
import IncludeExcludeFromFed from '../../components/OverviewCommands/includeExcludeFromFed';
import DomainPlanet from '../../components/OverviewCommands/domainPlanet';
import CreateStar from '../../components/OverviewCommands/createStar';
import DeleteStar from '../../components/OverviewCommands/deleteStart';
import GetStar from '../../components/OverviewCommands/getStar';
import CreateOrbit from '../../components/OverviewCommands/createOrbit';
import CreateSistema from '../../components/OverviewCommands/createSystem';
import Cookies from "js-cookie"

const Overview = () => {
    const [userClass, setUserClass] = useState('');
    const [isLeader, setIsLeader] = useState(false);
    const navigate = useNavigate();

    useEffect(() => {
        const uClass = Cookies.get("userClass"); 
        setUserClass(uClass);

        if(uClass != "COMANDANTE" && uClass != "OFICIAL" && uClass != "CIENTISTA" ){
            navigate('/');
            console.log("Erro");
        }

        setIsLeader(Cookies.get("userFaction") != "undefined");
    }, []);

    const handleLogoff = () => {
        document.cookie = "";
        navigate('/');
    };

    const leaderDashboard = ()=>(
        <>
            <div className={Styles.grupo} style={{width: '48%'}}>
                <div className={Styles.conteudo}>
                    <ChangeNameFacction nome={Cookies.get("userFaction")}/>
                </div>
                <div className={Styles.conteudo}>
                    <AddCommunity/>                    
                </div>
            </div>

            <div className={Styles.grupo} style={{width: '48%'}}>
                <div className={Styles.conteudo}>
                    <ChangeLeder/>
                </div>

                <div className={Styles.conteudo}>
                    <RemoveNation/>
                </div>
            </div>
        </>
    );

    const commanderDashboard = ()=>(
        <>
            <div className={Styles.conteudoPequeno}>
                <CreateNewFed/>
            </div>

            <div className={Styles.conteudoPequeno}>
                <IncludeExcludeFromFed/>
            </div>

            <div className={Styles.conteudoPequeno}>
                <DomainPlanet/>
            </div>
        </>
    );
    const scientistDashboard = ()=>(
        <>
            <div className={Styles.conteudo}>
                <CreateStar/>
            </div>
            <div className={Styles.conteudo}>
                <GetStar/>
            </div>     

            <div className={Styles.conteudo}>
                <CreateOrbit/>
            </div>   

            <div className={Styles.conteudo} style={{height: 'auto', width: '47.5%'}}>
                <CreateSistema/>
            </div>   
            <div className={Styles.conteudo} style={{height: 'auto',width: '47.5%'}}>
                <DeleteStar/>
            </div>       
       
        </>
    );

    return (
        <div className={Styles.container}>
            <div className={Styles.user}>
                <h2>Bem-vindo, {userClass === "CIENTISTA" ? "Dr(a)" : userClass} {Cookies.get("userName")}</h2>
                <div className={Styles.actions}>
                    <button onClick={()=>{navigate("/reports")}}>Ver Relatórios</button>
                    <button onClick={handleLogoff}>Logoff</button>
                </div>
            </div>
            <div className={Styles.dashboard}>
                {isLeader && leaderDashboard()}
                {userClass === "COMANDANTE" && commanderDashboard()}
                {userClass === "CIENTISTA" && scientistDashboard()}
            </div>



        </div>
    );
};

export default Overview;